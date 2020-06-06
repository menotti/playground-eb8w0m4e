# Começando com OpenCL

## Como o OpenCL funciona?

Uma implementação OpenCL consiste em dois componentes principais: (i) um compilador que compila seu código para dispositivos OpenCL, e (ii) uma biblioteca de tempo de execução  que fornece a interface de alto nível para escrever aplicativos OpenCL e o _runtime_ para executar o código do dispositivo em dispositivos OpenCL.

## Em que o OpenCL é executado?

O OpenCL pode atingir uma ampla variedade de dispositivos em qualquer sistema, como CPUs com vários núcleos, GPUs, FPGAs, DSPs e outros tipos de aceleradores e processadores especializados. 

O pacote OpenCL fornece uma ferramenta chamada `clinfo`, que pode ser usada para detectar dispositivos suportados no sistema.

Para fins de demonstração, podemos executar o `clinfo` aqui para exibir os dispositivos OpenCL disponíveis para este tutorial.

Clique no botão `Run` para ver como é sua saída:

@[OpenCL Info]({"command": "sh /project/target/validate.sh"})

* Observe que este tutorial está sendo executado em uma instância de nuvem e, portanto, está usando uma CPU Intel, não há GPU ou processador acelerador disponível.

Como você pode ver na saída de comando `clinfo`, o único dispositivo suportado é o "host", que é a CPU Intel. Embora seja improvável oferecer melhorias de desempenho na ausência de uma GPU, ele permite executar nosso código OpenCL.
