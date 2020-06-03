# Memória e sincronização SYCL: lendo informações do hardware

`size_t wgroup_size = 32;`

Definimos o tamanho do grupo de trabalho que será usado. Isso é definido manualmente como 32, que funcionará em todos os dispositivos, mas é importante entender como calcular o tamanho ideal do grupo de trabalho se você estiver otimizando para um hardware específico.

`auto part_size = wgroup_size * 2;`

Inicializamos uma variável `part_size` para ser o número de elementos na matriz que o grupo de trabalho reduz. Como cada item de trabalho reduz inicialmente dois elementos, é duas vezes o tamanho do grupo de trabalho.

```
if (!has_local_mem
      || local_mem_size < (wgroup_size * sizeof(int32_t)))
  {
       throw "Device doesn't have enough local memory!";
  }
```

Também testamos o dispositivo quanto ao tamanho da memória local - não podemos realizar a redução se houver muito pouco ou se a memória local não for totalmente suportada. Obviamente, em um aplicativo do mundo real, seria necessário um caso especial para também suportar esses dispositivos.

@[Redução paralela]({"stubs": ["src/exercises/memory_2.cpp"],"command": "sh /project/target/run.sh memory_2", "layout": "aside"})
