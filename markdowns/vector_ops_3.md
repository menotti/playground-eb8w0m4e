# Programação de _Kernel_ SYCL - A API single_task

## Declare o _kernel_ `vector_addition` 

### Descrição

Por especificação, um tipo sem nome é um argumento de modelo inválido para classes usadas para nomear _kernels_ SYCL. Portanto, você precisa pelo menos declarar a classe do _kernel_ antes de usá-la.

Os exemplos a seguir são nomes de _kernel_ SYCL válidos:

```cpp
// class
class MyKernelClass;
// struct
struct MyKernelStruct;
// enum class
enum class MyKernelEnum : int;
```

### Tarefa

Mais adiante, declare o functor da classe `vector_addition` antes do ponto de entrada `int main` da aplicação.

Localização no código fonte:

```cpp
// <<Declare vector_addition kernel function object>>
```

<details><summary>Dica</summary>
<p>

```cpp
class vector_addition;
```

</p>
</details>

## Implemente o _kernel_ `vector_addition` 

### Descrição

Agora precisamos enfileirar o _kernel_ de adição de vetores para execução.

Um _kernel_ que é executado em uma _thread_ usando `NDRange(1,1,1)` pode ser enfileirado usando a API `cl::sycl::single_task`:

```cpp
single_task<typename kernel_lambda_name>([=](){});
```

Isso é equivalente à execução de um _kernel_ em uma única unidade de computação com um único grupo de trabalho de apenas um item de trabalho. Assim, podemos acessar os valores dos objetos acessadores diretamente usando o índice `0` da seguinte maneira:

```cpp
// e.g, assign accessor element in the kernel body
acc[0] = someValue;
```

### Tarefa

Complete o código do _kernel_ de adição de vetores em que os acessadores de `a`, `b`, `c` disponibilizam os vetores para o cálculo de `c = a + b`.

Localização no código fonte:

```cpp
// <<Complete the vector addition computation>>
```

<details><summary>Dica</summary>
<p>

```cpp
c_acc[0] = a_acc[0] + b_acc[0];
```

</p>
</details>

# Vamos executar!

@[Olá mundo em SYCL]({"stubs": ["src/exercises/vector-ops_3.cpp"],"command": "sh /project/target/run.sh vector-ops_3", "layout": "aside"})
