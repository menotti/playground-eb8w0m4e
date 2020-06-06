# Blocagem de _loops_

## Multiplicação de matrizes

Por fim, temos a versão com blocagem, que explora melhor o uso das memórias cache. Experimente alterar o tamanho do bloco e compare os resultados, lembre-se que ele deve ser alterado no programa principal e também no _kernel_. 

@[Multiplicação de matrizes - OpenCL]({"stubs": ["src/exercises/matmul2db.cpp", "src/exercises/matmul.hpp", "src/exercises/kernels/C_block_form.cl"],"command": "sh /project/target/run.sh matmul2db", "layout": "aside"})
