# Manipulação de erros

Em geral, existem dois tipos de erros em SYCL. Estes são síncronos e assíncronos.

Erros síncronos são exceções clássicas do C++, lançadas sempre que o usuário chama uma função com argumentos errados. Estes podem ser capturados com um bloco `try...catch`.

Erros assíncronos, por outro lado, são aqueles que descrevem falhas no código executado de forma assíncrona, por exemplo, dentro de um grupo de comandos ou de um _kernel_. Como eles podem ocorrer em um quadro de pilha diferente, o erro assíncrono não pode ser propagado na pilha. Por padrão, eles são considerados 'perdidos'. A maneira pela qual podemos recuperá-los é fornecendo uma função de tratamento de erros.

## Criando um manipulador de exceções

O manipulador é um objeto de função que aceita um parâmetro `exception_list`. O parâmetro é uma lista iterável de objetos `std::exception_ptr`. Em nosso manipulador simples, repetimos o ponteiro (não há como ler diretamente), capturamos e exibimos a descrição da exceção.

```
auto exception_handler = [] (sycl::exception_list exceptions) {
```

## Execução com parâmetros errados

Configuramos uma fila padrão e fornecemos um _kernel_ inválido. A razão pela qual esse código está incorreto não é importante por enquanto (tem a ver com tamanhos de grupos de trabalho). Finalmente, chamamos `queue::wait_and_throw`. Essa função bloqueia e aguarda a conclusão de todas as tarefas enfileiradas. Em seguida, ele envia todas as exceções assíncronas ao nosso manipulador. Além disso, é possível, mas muito improvável, lançar diretamente uma exceção síncrona. Para ser completo, também capturamos.

```
queue.submit([&] (sycl::handler& cgh) {
   auto range = sycl::nd_range<1>(sycl::range<1>(1), sycl::range<1>(10));
   cgh.parallel_for<class invalid_kernel>(range, [=] (sycl::nd_item<1>) {});
});
```

Você pode estar se perguntando por que o manipulador de exceções precisa usar uma lista de exceções em vez de uma única exceção como argumento. Uma única solicitação `wait_and_throw` pode relatar várias exceções, portanto, é conveniente agrupá-las em um objeto de lista. Cada solicitação possui uma lista única correspondente, portanto, o usuário não se encarrega de verificar manualmente quais erros estão em qual grupo.

## Vamor executar!

Este exemplo lança intencionalmente uma exceção e podemos ver sua saída

@[Tratamento de erros em SYCL]({"stubs": ["src/exercises/error_handling.cpp"],"command": "sh /project/target/run.sh error_handling", "layout": "aside"})
