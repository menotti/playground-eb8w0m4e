# Olá mundo

Este primeiro exercício o guiará pelas etapas envolvidas na criação do sua primeira aplicação OpenCL. Trabalharemos com o equivalente a um "olá mundo" para programação paralela, uma adição de vetores. Ela adicionará dois vetores, mas crucialmente o OpenCL permitirá que essa adição seja feita em paralelo.

## Incluindo o arquivo de cabeçalho OpenCL

A primeira linha em toda aplicação OpenCL deve incluir o arquivo de cabeçalho `CL/cl.hpp`.

`#include <CL/cl.hpp>`

## Configurar armazenamento do _host_

No `main`, começamos configurando o armazenamento do _host_ para os dados nos quais queremos operar. Nosso objetivo é calcular `c = a + b`, onde as variáveis são vetores. Para nos ajudar a conseguir isso, o SYCL fornece o tipo `vec<T, size>`, que é um vetor de um tipo escalar básico. Ele possui parâmetros de _template_ para o tipo escalar e o tamanho. Ele deve ser usado mais como um vetor geométrico do que `std::vector` e, portanto, suporta apenas tamanhos de até 16. Mas não se desespere, existem várias maneiras de trabalhar com conjuntos maiores de dados. Usamos `float4`, que é apenas `vec<float, 4>`.

```
sycl::float4 a = { 1.1, 2.2, 3.3, 4.4 };
sycl::float4 b = { 4.4, 3.3, 2.2, 1.1 };
sycl::float4 c = { 0.0, 0.0, 0.0, 0.0 };
```

## Selecionando seu dispositivo

Em SYCL, existem diferentes maneiras de configurar e selecionar os dispositivos que queremos usar. O SYCL fornece um seletor padrão que tenta selecionar o dispositivo mais apropriado no seu sistema. É possível usar um seletor personalizado, mas como temos apenas um dispositivo, usamos o seletor padrão.

`cl::sycl::default_selector selector;`

## Configurando uma fila (Queue) SYCL

Para enviar nossas tarefas para serem agendadas e executadas no dispositivo de destino, precisamos usar uma fila (Queue) SYCL. Configuramos isso e passamos a ela nosso seletor para que ele saiba qual dispositivo selecionar ao executar as tarefas.

`cl::sycl::queue myQueue(selector);`

## Configurar armazenamento do dispositivo

Na maioria dos sistemas, o _host_ e o dispositivo não compartilham memória física. Por exemplo, a CPU pode usar RAM e a GPU pode usar sua própria VRAM interna. O SYCL precisa saber quais dados serão compartilhados entre o _host_ e os dispositivos.

Para esse fim, existem _buffers_ SYCL. A classe `buffer<T, dims>` é genérica sobre o tipo de elemento e o número de dimensões, que podem ser uma, duas ou três. Quando passado um ponteiro bruto, como neste caso, o construtor `buffer(T* ptr, range_size)` assume a propriedade da memória pela qual foi passado. Isso significa que absolutamente não podemos usar essa memória enquanto o _buffer_ existe, e é por isso que começamos um escopo C++ (usando `{...}` para delimitá-lo). No final de seu escopo, os _buffers_ serão destruídos e a memória retornada ao usuário. O argumento `range_size` é um objeto de intervalo <dims>, que precisa ter o mesmo número de dimensões que o _buffer_ e é inicializado com o número de elementos em cada dimensão. Aqui, temos uma dimensão com um elemento.

Os buffers não estão associados a uma fila ou contexto específico, portanto, eles são capazes de manipular dados de forma transparente entre vários dispositivos. Eles também não exigem informações de leitura/gravação, pois isso é especificado por operação.

```
sycl::buffer<sycl::float4, 1> a_sycl(&a, sycl::range<1>(1));
sycl::buffer<sycl::float4, 1> b_sycl(&b, sycl::range<1>(1));
sycl::buffer<sycl::float4, 1> c_sycl(&c, sycl::range<1>(1));
```

## Executando o _kernel_

### Criando um grupo de comandos

Tudo consiste tecnicamente em uma única chamada de função para `queue::submit`. `submit` aceita um parâmetro de objeto de função, que encapsula um grupo de comandos. Para esse propósito, o objeto de função aceita um manipulador de grupo de comandos `cgh` construído pelo _runtime_ SYCL e entregue a nós como argumento. Todas as operações usando um determinado manipulador de grupo de comandos fazem parte do mesmo grupo de comandos.

`myQueue.submit([&](cl::sycl::handler &cgh)`

Um grupo de comandos é uma maneira de encapsular uma operação do lado do dispositivo e todas as suas dependências de dados em um único objeto, agrupando todos os comandos relacionados (chamadas de função). Efetivamente, o que isso alcança é impedir condições de corrida de dados, vazamento de recursos e outros problemas, permitindo que o _runtime_ SYCL conheça os pré-requisitos para executar corretamente o código do lado do dispositivo.

### Acessadores de dados (_Data Accessors_)

Em nosso grupo de comandos, primeiro configuramos os acessadores. Em geral, esses objetos definem as entradas e saídas de uma operação do lado do dispositivo. Os acessadores também fornecem acesso a várias formas de memória. Nesse caso, eles nos permitem acessar a memória pertencente aos _buffers_ criados anteriormente. Passamos a propriedade de nossos dados para o _buffer_, para que não possamos mais usar os objetos `float4`, e os acessadores são a única maneira de acessar dados em objetos de _buffer_.

```
auto a_acc = a_sycl.get_access<sycl::access::mode::read>(cgh);
auto b_acc = b_sycl.get_access<sycl::access::mode::read>(cgh);
auto c_acc = c_sycl.get_access<sycl::access::mode::discard_write>(cgh);
```

O método `buffer::get_access(handler&)` usa um argumento do modo de acesso. Usamos `access::mode::read` para os argumentos e `access::mode::discard_write` para o resultado. `discard_write` pode ser usado sempre que escrevemos em todo o _buffer_ e não nos importamos com o conteúdo anterior. Como ele será totalmente sobrescrito, podemos descartar o que havia antes.

O segundo parâmetro é o tipo de memória da qual queremos acessar os dados. Veremos os tipos de memória disponíveis na seção sobre acessos à memória. Por enquanto, usamos o valor padrão.

### Definindo uma função do _kernel_

No SYCL, existem várias maneiras de definir uma função do _kernel_ que será executada em um dispositivo, dependendo do tipo de paralelismo desejado e dos diferentes recursos necessários. A mais simples delas é a função `cl::sycl::handler::single_task`, que utiliza um único parâmetro, sendo um objeto de função C++ e executa esse objeto de função exatamente uma vez no dispositivo. O objeto da função C++ não aceita nenhum parâmetro, no entanto, é importante observar que, se o objeto da função for um _lambda_, ele deverá capturar por valor e, se for uma estrutura ou classe, deverá definir todos os membros como membros por valor.

```
   cgh.single_task<class vector_addition>([=] () {
      c_acc[0] = a_acc[0] + b_acc[0];
   });
});
```

## Limpando

Um dos recursos do SYCL é o uso do C++ RAII (resource aquisition is initialisation: aquisição de recursos é inicialização), o que significa que não há limpeza explícita e tudo é feito por meio dos destruidores de objetos SYCL.
```
{
   ...
}
```

# Vamos executar!

@[Olá mundo em SYCL]({"stubs": ["src/exercises/hello_world.cpp"],"command": "sh /project/target/run.sh hello_world", "layout": "aside"})
