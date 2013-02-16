declare -a arr=(br-abnt2 us en);

function layout_teclado() {
  for i in ${arr[br-abnt2]}; do
    echo $i;
  done
}
