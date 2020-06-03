# Memória e sincronização SYCL

Enquanto para cálculos simples não há problema em operar apenas em itens de trabalho, qualquer carga de trabalho mais complexa exigirá controle mais refinado. Infelizmente, isso tem o custo de introduzir alguma complexidade. Felizmente, podemos esclarecer tudo!

Você deve se lembrar que os itens de trabalho são agrupados em grupos de trabalho. A divisão em grupos de trabalho não é puramente conceitual - tem implicações muito reais nos acessos e desempenho da memória. Os grupos de trabalho são independentes um do outro. De fato, não há como sincronizar entre eles em um único _kernel_. Por esse motivo, dois grupos de trabalho nunca devem gravar no mesmo local de memória (embora possam ler dados compartilhados).

OpenCL e SYCL definem uma distinção clara entre várias regiões na memória e regras que governam os acessos a elas. Tudo no lado da CPU é conhecido como memória do _host_. Não é acessível diretamente a partir dos _kernels_, mas, como vimos, _buffers_ e acessadores fornecem recursos para copiar dados do _host_ para o dispositivo e acessá-los lá. O destino do acessador correspondente é `access::target::host_buffer`.

No lado do dispositivo, existem mais regiões de memória:

* A memória global está disponível da mesma forma para todos os grupos de trabalho e itens. Pode ser considerado um equivalente de RAM do lado do dispositivo. O destino correspondente, `access::target::global_buffer`, é o destino padrão para `buffer::get_access`. Nos exemplos anteriores, não especificamos explicitamente um destino, portanto este foi usado.

* A memória local é específica para um único grupo de trabalho. Grupos de trabalho não podem acessar a memória local de outros, mas ela é compartilhada entre todos os itens de trabalho de um grupo. Pode ser pensado como um cache controlado pelo usuário. É especialmente útil para problemas de dividir e conquistar, onde cada parte da computação é tratada por um grupo de trabalho. A memória local pode ser usada para armazenar o resultado de tal cálculo. A memória local é alocada por execução do _kernel_ e não pode ser preenchida com dados do _host_, portanto, você deve inicializá-la. A maneira canônica de alocá-la é criar um acessador `access::target::local` dentro de um grupo de comandos, passando o tamanho de alocação solicitado.

* Memória privada é uma pequena região dedicada a cada item de trabalho. É muito parecida com os registradores da CPU. Todas as variáveis criadas em um _kernel_ são armazenadas na memória privada. Além disso, objetos `private_memory` dedicados podem ser criados para essa finalidade.

* Finalmente, a memória constante é uma parte somente leitura da memória global, que também pode fazer referência a um _buffer_ do lado do _host_.

Neste exemplo, tentaremos calcular uma redução de matriz - a soma de todos os seus elementos. A estrutura geral do exemplo é mostrada no console. Você pode ver o código que inicializa uma matriz de valores aleatórios a serem adicionados e imprime esses valores.

```
std::cout << "Data: ";
  for (auto& el : arr) {
    el = idist(mt_engine);
    std::cout << el << " ";
  }
```

## Redução paralela

No momento, esse código simplesmente exibe o conteúdo da matriz na posição 0, pois nenhuma operação foi realizada na matriz.

@[Redução paralela]({"stubs": ["src/exercises/memory_1.cpp"],"command": "sh /project/target/run.sh memory_1", "layout": "aside"})


