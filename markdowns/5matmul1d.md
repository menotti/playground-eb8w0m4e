# Usando memória local

## Multiplicação de matrizes

Aqui temos implementações diferentes, onde cada invocação do _kernel_ calcula uma linha inteira da matriz. Note que nosso `NDRange` agora só tem uma dimensão e que no kernel (`C_row.cl`) só solicitamos o `get_global_id` para ela, já que a outra é percorrida por um `for` na variável `k`. Esta primeira versão apresenta desempenho pior do que a da lição anterior, ao menos na CPU. Experimente as outras duas versões desta lição alternando os comentários no programa principal. Note que na última versão (`C_row_priv_block.cl`) você precisa declarar um `NDRange` local e passa-lo como argumento no _kernel_, pois ele usa as funções `get_local_id` e `get_local_size`, além de alocar memória local.   

@[Multiplicação de matrizes - OpenCL]({"stubs": ["src/exercises/matmul1d.cpp", "src/exercises/matmul.hpp", "src/exercises/kernels/C_row.cl", "src/exercises/kernels/C_row_priv.cl", "src/exercises/kernels/C_row_priv_bloc.cl"],"command": "sh /project/target/run.sh matmul1d", "layout": "aside"})
