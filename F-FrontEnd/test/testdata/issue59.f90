MODULE mod1
  IMPLICIT NONE
  PRIVATE

  TYPE, BIND(c) :: t_rt
    INTEGER :: i
  END TYPE t_rt
END MODULE mod1
