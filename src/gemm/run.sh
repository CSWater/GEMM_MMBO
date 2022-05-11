#!/bin/bash  
for M in {44160..384..-384}
do
  ./benchmark 1 ${M} 2048 384 ${M} 2048 44160
done

#while read m n k lda ldb ldc
#do
#  ./benchmark 1 ${m} ${n} ${k} ${lda} ${ldb} ${ldc}
#done < mnk_uniq
