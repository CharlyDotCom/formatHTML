variable='13423exa*lkco3nr*swkjenve*kejnv'
IFS='*' read -a array <<< "$variable"
echo "${array[2]}"