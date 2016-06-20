#!/bin/bash

#-------------------------------------------------------
#  GET INTERFACE TYPE 8
#  generator for xmp_coarray_get.h
#  see also ../src/xmpf_coarray_get_wrap.f90{,.sh}
#-------------------------------------------------------

#--------------------
#  sub
#--------------------
echo72 () {
    str="$1                                                                        "
    str=`echo "$str" | cut -c -72`"&"
    echo "$str"
}

print_function_scalar() {
    tk=$1
    typekind=$2

    echo   '!-----------------------------------------------------------------------'
    echo72 "      function xmpf_coarray_get0d_${tk}(descptr, coindex, mold)"
    echo   '     &   result(dst)'
    echo   '!-----------------------------------------------------------------------'
    echo   '      integer(8), intent(in) :: descptr'
    echo   '      integer, intent(in) :: coindex'
    echo   "      ${typekind}, intent(in) :: mold"
    case ${typekind} in
        'character(*)')  echo    "      character(len=len(mold)) :: dst";;
        *)               echo    "      ${typekind} :: dst";;
    esac

    echo   '      end function'
    echo   ''
}


print_function_array() {
    tk="$1"
    typekind="$2"

    echo    '!-----------------------------------------------------------------------'
    echo72  "      function xmpf_coarray_get${DIM}d_${tk}(descptr, coindex, mold)"
    echo    '     &   result(dst)'
    echo    '!-----------------------------------------------------------------------'
    echo    '      integer(8), intent(in) :: descptr'
    echo    '      integer, intent(in) :: coindex'

    echo -n "      ${typekind}, intent(in) :: mold("
    sep=''
    for i in `seq 1 ${DIM}`; do
        echo -n "${sep}:"
        sep=','
    done
    echo ')'

    case ${typekind} in
        'character(*)')  echo72  "      character(len=len(mold)) ::";;
        *)               echo72  "      ${typekind} ::";;
    esac
    if test ${DIM} -le 4; then
        sep='     &   dst( '
        for i in `seq 1 ${DIM}`; do
            echo -n "${sep}size(mold,$i)"
            sep=', '
        done
    else
        echo72  '     &   dst( size(mold,1), size(mold,2), size(mold,3), size(mold,4),'
        sep='     &        '
        for i in `seq 5 ${DIM}`; do
            echo -n "${sep}size(mold,$i)"
            sep=', '
        done
    fi
    echo    ' )'

    echo   '      end function'
    echo   ''
}


print_function() {
    case ${DIM} in
        0) print_function_scalar "$@" ;;
        *) print_function_array  "$@" ;;
    esac
}



#--------------------
#  main
#--------------------
TARGET=$1

echo "!! This file is automatically generated by $0"
echo '!! GET INTERFACE TYPE 8'
echo '!!'
echo '!! RESTRICTIONS in XMP/F'
echo '!!  - Quadruple precision real and complex are not supported.'
echo '!!  - The number of array dimensions cannot exceed 7.'
echo '!!'
echo ''
echo '      interface xmpf_coarray_get_generic'
echo ''

for DIM in `seq 0 7`
do
    if test "sxace-nec-superux" != "$TARGET"; then    ## integer(2) cannot be used on SX-ACE
	print_function i2  "integer(2)"
    fi
    print_function i4  "integer(4)"      
    print_function i8  "integer(8)"
    if test "sxace-nec-superux" != "$TARGET"; then    ## logical(2) cannot be used on SX-ACE
	print_function l2  "logical(2)"
    fi
    print_function l4  "logical(4)"      
    print_function l8  "logical(8)"      
    print_function r4  "real(4)"         
    print_function r8  "real(8)"         
    print_function z8  "complex(4)"      
    print_function z16 "complex(8)"      
    print_function cn  "character(*)" 
done

echo '      end interface'
echo ''

exit