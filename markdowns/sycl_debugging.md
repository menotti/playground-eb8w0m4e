# Depurando SYCL

### Depurando no _host_

Uma diferença importante entre SYCL e OpenCL é que, embora os _kernels_ OpenCL possam ser executados apenas em dispositivos OpenCL, um _kernel_ SYCL também pode ser executado no dispositivo _host_ SYCL. Este modo não requer uma implementação OpenCL para a CPU e pode ser usado quando não tivermos uma disponível. Além disso, nesse modo, o código é executado como código de máquina padrão e pode ser depurado como tal. Isso significa que os problemas em seus _kernels_ SYCL podem ser encontrados com muita facilidade, sem a necessidade de recorrer a depuradores específicos de dispositivos e manipulação de hardware desajeitada. Você pode usar o depurador de sua escolha e interromper a qualquer momento dentro de um _kernel_. Se a invocação for um `parallel_for`, o código do _host_ gerará _threads_ do SO, portanto, métodos padrão de depuração _multithread_ podem ser aplicados.

### Depurando no dispositivo

Isso funciona bem na maioria das vezes, mas nem todos os tipos de problemas podem ser depurados dessa maneira. Se um problema ocorrer apenas durante a execução em um dispositivo OpenCL, ele deverá ser analisado de maneira diferente. Existem vários pontos em que algo pode dar errado. Na maioria das vezes, é um erro do usuário - algo a ver com diferentes larguras de tipo, uma corrida de dados que só pode ser observada no modo de dispositivo etc.

Em casos como esses, pode ser necessário depurar o código em execução no OpenCL ou mesmo no hardware específico. Existem algumas ferramentas para tornar esse processo um pouco menos doloroso:
* `Oclgrind` simula um ambiente OpenCL completo que pode detectar uma variedade de erros que não necessariamente se manifestam no modo _host_.
* `GPUVerify` é uma ferramenta de análise formal que pode 'provar' que um trecho de código está correto em certos aspectos. Infelizmente, ele aceita apenas código OpenCL C, o que significa que você teria que traduzir seu _kernel_ SYCL.
* Os fornecedores de hardware geralmente fornecem ferramentas de depuração específicas para seus dispositivos.

### Imprimir _stream_

O construtor `cl::sycl::stream` recebe dois números - o tamanho máximo do _buffer_ e o tamanho máximo da instrução. O tamanho do _buffer_ controla quantos bytes no total podem ser enviados pelo fluxo na chamada do _kernel_. O tamanho da instrução controla quantos bytes podem ser produzidos em uma única instrução, ou seja, tudo entre o primeiro stream::operator `<<` e o ponto e vírgula. Por exemplo, em `<< a << b << '\n';`, o tamanho máximo da instrução é um limite para `sizeof(a) + sizeof(b) + sizeof('\n')`. O último parâmetro é o grupo de comandos no qual o fluxo será usado.

No _kernel_, produzimos uma string e um manipulador de nova linha - o SYCL fornece alguns manipuladores análogos aos da biblioteca padrão C++.

@[Imprimir stream]({"stubs": ["src/exercises/sycl_debugging.cpp"],"command": "sh /project/target/run.sh sycl_debugging", "layout": "aside"})
