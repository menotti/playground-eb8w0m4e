# Memória e sincronização SYCL: loop de redução

`auto n_wgroups = (len + part_size - 1) / part_size;`

Dentro do ciclo de redução, encontramos primeiro o número de grupos de trabalho para essa etapa de redução. É o tamanho que resta a ser reduzido dividido pelo número de elementos que cada grupo de trabalho reduz.

`sycl::accessor<int32_t, 1, sycl::access::mode::read_write, sycl::access::target::local> local_mem(sycl::range<1>(wgroup_size)`

Em seguida, no grupo de comandos, alocamos uma parte da memória local criando um acessador com `access::target::local` e um intervalo igual ao tamanho do grupo de trabalho. Verificamos o tamanho da memória anteriormente, então sabemos que ele está disponível. Como mencionado acima, essa região da memória parece diferente para cada grupo de trabalho e seu uso é para armazenamento temporário.

Você pode se perguntar: por que nos preocupamos em usar a memória local quando podemos realizar toda a operação em nível global? A resposta é que é muito mais rápido. A memória local (geralmente) é fisicamente mais próxima do chip do que a global e não sofre de problemas como o compartilhamento falso, uma vez que é exclusiva para cada unidade de computação. Portanto, é uma boa idéia sempre executar todas as operações temporárias na memória local para obter o melhor desempenho.

`auto global_mem = buf.get_access<sycl::access::mode::read_write>(cgh);`

Também obtemos um acessador para os dados disponíveis na memória global. Dessa vez, o `get_access` é explicitamente qualificado com `access::target::global_buffer`, enquanto anteriormente assumia esse valor por padrão.

```
cgh.parallel_for<class reduction_kernel>(
      sycl::nd_range<1>(n_wgroups * wgroup_size, wgroup_size),
      [=] (sycl::nd_item<1> item)
```

Por fim, lançamos um kernel paralelo. Usamos a variante `nd_range`, que nos permite especificar o tamanho global e local. O construtor `nd_range` recebe dois objetos de intervalo da mesma dimensionalidade que ele. O primeiro descreve o número de itens de trabalho por dimensão (lembre-se de que pode haver até três dimensões). O segundo argumento de intervalo para `nd_range<n>` descreve o número de itens de trabalho em um grupo de trabalho. Para encontrar o número de grupos de trabalho por dimensão, divida o primeiro argumento pelo segundo. Nesse caso, o resultado é `n_wgroups`, que é quantos grupos de trabalho serão instanciados. Nesta variante, o kernel lambda usa um argumento `nd_item`. Ele representa o item de trabalho atual e os métodos de recursos para obter informações detalhadas, como informações locais, globais e de grupo de trabalho.

Como cada etapa do ciclo de redução produz um número por grupo de trabalho, configuramos o `len` como `n_wgroups` a cada iteração, o que continuará reduzindo nos resultados.

@[Redução paralela]({"stubs": ["src/exercises/memory_3.cpp"],"command": "sh /project/target/run.sh memory_3", "layout": "aside"})
