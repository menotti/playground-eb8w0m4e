# Usando memória local

Agora, carregaremos os dados na memória local, como explicamos antes, usar a memória local pode fornecer melhorias significativas de desempenho.

```
  size_t local_id = item.get_local_linear_id();
  size_t global_id = item.get_global_linear_id();

  local_mem[local_id] = 0;

  if ((2 * global_id) < len) {
    local_mem[local_id] = global_mem[2 * global_id] + global_mem[2 * global_id + 1];
  }

  item.barrier(sycl::access::fence_space::local_space);
```

No _kernel_, primeiramente inicializamos a memória local com zeros, pois ela pode de fato conter lixo. O ponto principal aqui é que `0` é invariável em nossa redução, significando que `x + 0 = x`, para que possamos adicionar toda a matriz com segurança, mesmo que ela não esteja totalmente preenchida com dados a serem reduzidos. 

Dividimos nossos dados em partes, cada uma sendo computada por um único grupo de trabalho. Os dados de entrada devem ter tamanho uniforme, mas não precisam ser múltiplos do tamanho do grupo de trabalho. Portanto, alguns itens de trabalho no último grupo de trabalho podem não ter dados correspondentes. Por esse motivo, o carregamento inicial da memória global para a local é protegido por uma instrução `if`. Como mencionado na seção "paralelismo", isso geralmente é uma má idéia. Nesse caso, no entanto, tudo bem, porque no máximo um grupo de trabalho terá itens de trabalho divergentes. Utilizamos uma pequena matriz para fins de ilustração e um _kernel_ especializado seria tecnicamente mais rápido, mas qualquer caso de uso real pode ter muito mais dados de entrada. 

Depois que a carga é executada com a adição dos dois elementos correspondentes a cada item de trabalho, emitimos uma barreira com uma cerca de memória local. Temos que parar um pouco e entender por que isso é necessário. No modelo de memória OpenCL, todas as operações nos itens de trabalho têm semântica relaxada. Por exemplo, no pseudocódigo a seguir, executamos duas funções em paralelo sobre os mesmos dados:

### Pseudo código com gravação relaxada

```
  int x = 0;
  int y = 0;

  void thread_a() {
    write(x, 1);
    write(y, 2);
  }

  void thread_b() {
    int ly = load(y);
    int lx = load(x);
    printf("%i %i", lx, ly);
  }

  in_parallel(thread_a, thread_b);
```

Em um modelo de memória relaxada, o item de trabalho B pode realmente imprimir 0 2. Isso parece errado, porque o item de trabalho A deve ter gravado x na memória antes de escrever y. O ponto principal é que o item de trabalho da operação B pode observar as operações de A em uma ordem diferente. Isso 'realmente' ajuda no desempenho do hardware, mas tem um custo de comportamento confuso. Para lidar com esse problema, precisamos emitir cercas de memória. Além disso, mesmo que não nos importemos em reordenar, podemos querer garantir que todos os resultados das operações de gravação sejam propagados entre itens de trabalho - caso contrário, eles podem permanecer no cache por item de trabalho e não ficar visíveis entre os itens de trabalho.

Para sincronizar o estado da memória, usamos a operação `item::barrier(access::fence_space)`. Uma barreira SYCL faz duas coisas. Em primeiro lugar, garante que cada item de trabalho dentro do grupo de trabalho atenda à chamada de barreira. Em outras palavras, garante que o grupo de trabalho seja sincronizado em um determinado ponto do código. É muito importante garantir que "todos os itens de trabalho cheguem à barreira ou nenhum". Por exemplo, o seguinte código é inválido:

### Barreiras separadas

```
  if (local_id < 5) {
    item.barrier(sycl::access::fence_space::local_space);
  } else {
    item.barrier(sycl::access::fence_space::local_space);
  }
```

Parece inocente, mas o problema é que as duas instruções não são a mesma barreira. Os itens de trabalho abaixo do `local_id` 5 chegarão à primeira barreira, enquanto os demais chegarão à outra e a execução será interrompida, os dois grupos esperando um pelo outro para sempre. Uma simples transformação de fatorar a chamada de barreira para fora do condicional o consertaria.

Em segundo lugar, `item::barrier` emite uma cerca de memória no espaço especificado. Pode ser `access::fence_space::local_space`, `::global_space` ou `::global_and_local`. Uma cerca garante que o estado do espaço especificado seja consistente em todos os itens de trabalho do grupo de trabalho. É importante ressaltar que 'não é possível' sincronizar entre grupos de trabalho. Eles são totalmente independentes e qualquer gravação ou leitura na mesma área de memória global realizada por dois grupos de trabalho é uma corrida de dados. Por esse motivo, é importante garantir que cada grupo de trabalho funcione apenas em uma região dedicada da memória global sem cruzamento.

Em seguida, reduzimos a matriz de cada grupo de trabalho na memória local:

### Reduzir em um elemento
```
  for (size_t stride = 1; stride < wgroup_size; stride *= 2) {
    auto idx = 2 * stride * local_id;
    if (idx < wgroup_size) {
      local_mem[idx] = local_mem[idx] + local_mem[idx + stride];
    }

    item.barrier(sycl::access::fence_space::local_space);
  }
```

Como cada iteração do loop `for` depende da anterior, emitimos uma barreira sempre para sincronizar itens de trabalho.

Por fim, escreva um número único que seja o resultado da redução desse grupo de trabalho na memória global.

### Gravar resultado do grupo na memória global

```
  if (local_id == 0) {
    global_mem[item.get_group_linear_id()] = local_mem[0];
  }
```

O resultado é obtido se você pressionar o botão "Run" abaixo:

@[Redução Paralela]({"stubs": ["src/exercises/memory_4.cpp"],"command": "sh /project/target/run.sh memory_4", "layout": "aside"})
