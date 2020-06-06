# Um exemplo completo

## Multiplicação de matrizes

Agora vamos analisar um exemplo completo de multiplicação de matrizes em C++ que envia dados para processamento e os recebe de volta. Além das diferenças inerentes da linguagem, temos algumas novidades em relação ao nosso exemplo anterior. 

O _kernel_ é criado na seguinte linha:

```c++
// Create the compute kernel from the program
cl::make_kernel<int, cl::Buffer, cl::Buffer, cl::Buffer> naive_mmul(program, "mmul");
```

Depois, ele é invocado diretamente pelo seu nome, mas antes declaramos um objeto `NDRange` que estipula suas dimensões e tamanhos:

```c++
cl::NDRange global(N, N);
naive_mmul(cl::EnqueueArgs(queue, global), N, d_a, d_b, d_c);
```
Os _kernels_ OpenCL podem trabalhar com 1, 2 ou 3 dimensões. Neste exemplo, estamos usando 2 dimensões e cada instância do _kernel_ vai calcular um único elemento da matriz. Observe no código do _kernel_ que está na última aba as seguintes linhas:

```c
int i = get_global_id(0);
int j = get_global_id(1);
```
A função `get_global_id` retorna um identificador único em cada dimensão (`0` e `1`) para cada uma das N x N execuções, cobrindo toda a matriz. 

@[Multiplicação de matrizes - OpenCL]({"stubs": ["src/exercises/matmul2d.cpp", "src/exercises/matmul.hpp", "src/exercises/kernels/C_elem.cl"],"command": "sh /project/target/run.sh matmul2d", "layout": "aside"})
