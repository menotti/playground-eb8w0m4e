# Olá mundo

Como de costume em qualquer tutorial de programação, vamos começar por este [olá mundo](https://us.fixstars.com/products/opencl/book/OpenCLProgrammingBook/first-opencl-program/) adaptado de um livro gratuito disponível na internet. O programa não faz nenhum cálculo, apenas retorna a mensagem **"Hello, World!"** gerada no _kernel_. Como a entrada e saída padrão do sistema não podem ser usadas a partir do _kernel_, ele apenas vai preencher a cadeia de caracteres e enviá-la ou programa principal que irá imprimi-la na console. 

## Incluindo o arquivo de cabeçalho OpenCL

Toda aplicação OpenCL deve incluir o arquivo de cabeçalho `CL/cl.h`:

```c
#include <CL/cl.h>
```

Mas antes disso, nós estamos definindo `CL_USE_DEPRECATED_OPENCL_1_2_APIS` para usar a versão 1.2 da API sem gerar _warnings_ durante a compilação:

```c
#define CL_USE_DEPRECATED_OPENCL_1_2_APIS
```

Esta versão não é a mais recente, mas é suportada pela maioria dos dispositivos OpenCL. 

## Configuração no _host_

No `main`, nós definimos uma série de variáveis cujos tipos, definidos na biblioteca OpenCL, possuem o prefixo `cl_` que explicaremos a seguir: 

```c
cl_device_id device_id = NULL;
cl_context context = NULL;
cl_command_queue command_queue = NULL;
cl_mem memobj = NULL;
cl_program program = NULL;
cl_kernel kernel = NULL;
cl_platform_id platform_id = NULL;
cl_uint ret_num_devices;
cl_uint ret_num_platforms;
cl_int ret;
```

## Configurando uma fila (Queue) OpenCL

Para enviar nossas tarefas para serem agendadas e executadas no dispositivo de destino, precisamos usar uma fila (Queue) OpenCL associada a um dispositivo. Primeiro pegamos o primeiro dispositivo da primeira plataforma disponível:

```
/* Get Platform and Device Info */
ret = clGetPlatformIDs(1, &platform_id, &ret_num_platforms);
ret = clGetDeviceIDs(platform_id, CL_DEVICE_TYPE_DEFAULT, 1, &device_id, &ret_num_devices);
```

Depois criamos um contexto de execução e uma fila associada e este contexto:
```
/* Create OpenCL context */
context = clCreateContext(NULL, 1, &device_id, NULL, NULL, &ret);

/* Create Command Queue */
command_queue = clCreateCommandQueue(context, device_id, 0, &ret);
```
É possível criar contextos com vários dispositivos, mas cada fila está associada e um único dispositivo. 

## Configurar armazenamento do dispositivo

Na maioria dos sistemas, o _host_ e o dispositivo não compartilham memória física. Por exemplo, a CPU pode usar RAM e a GPU pode usar sua própria VRAM interna. O OpenCL precisa saber quais dados serão compartilhados entre o _host_ e os dispositivos.

Para esse fim, existem _buffers_ OpenCL. A função a seguir cria um _buffer_ que pode ser lido e escrito (`CL_MEM_READ_WRITE`). 

```c
/* Create Memory Buffer */
memobj = clCreateBuffer(context, CL_MEM_READ_WRITE,MEM_SIZE * sizeof(char), NULL, &ret);
```

## Compilando o _kernel_

Os próximos passos são criar (`clCreateProgramWithSource`) e compilar (`clBuildProgram`) um programa que resultará em uma bibliteca dinâmica para o dispositivo alvo. Nosso único _kernel_ está armazenado em um arquivo externo (`hello.cl`), mas ele poderia conter mais de um, então precisamos indicar o seu nome `hello` como argumento na função `clCreateKernel`:

```c
/* Create Kernel Program from the source */
program = clCreateProgramWithSource(context, 1, (const char **)&source_str,
(const size_t *)&source_size, &ret);

/* Build Kernel Program */
ret = clBuildProgram(program, 1, &device_id, NULL, NULL, NULL);

/* Create OpenCL Kernel */
kernel = clCreateKernel(program, "hello", &ret);
```

## Executando o _kernel_ 

Agora basta atribuir o argumento que será usado no _kernel_ e enfileirar sua execução na fila do dispositivo:

```c
/* Set OpenCL Kernel Parameters */
ret = clSetKernelArg(kernel, 0, sizeof(cl_mem), (void *)&memobj);

/* Execute OpenCL Kernel */
ret = clEnqueueTask(command_queue, kernel, 0, NULL,NULL);
```

Nosso _kernel_ não recebe nenhum dado do _host_, mas quando for necessário, é preciso enviar os dados antes da execução usando `clEnqueueWriteBuffer`. 

## Lendo e exibindo o resultado

Após a execução, enfileiramos a transferência dos dados do dispositivo para _host_ com a função `clEnqueueReadBuffer` que tem como destino a `string` declarada no _host_ e a exibimos:

```c
/* Copy results from the memory buffer */
ret = clEnqueueReadBuffer(command_queue, memobj, CL_TRUE, 0,
MEM_SIZE * sizeof(char),string, 0, NULL, NULL);

/* Display Result */
puts(string);
```

## Limpando

Como estamos usando a versão C da API, precisamos desalocar os recursos:

```c
/* Finalization */
ret = clFlush(command_queue);
ret = clFinish(command_queue);
ret = clReleaseKernel(kernel);
ret = clReleaseProgram(program);
ret = clReleaseMemObject(memobj);
ret = clReleaseCommandQueue(command_queue);
ret = clReleaseContext(context);

free(source_str);
```

Isso pode não ser necessário em linguagens de programação mais modernas como C++, Python e Java. 

# Vamos executar!

@[Hello World - OpenCL]({"stubs": ["src/exercises/hello_world.cpp", "src/exercises/kernels/hello.cl"],"command": "sh /project/target/run.sh hello_world", "layout": "aside"})
