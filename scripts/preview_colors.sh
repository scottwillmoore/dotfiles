# name: preview_colors.sh
# author: scott moore
# description:
#	print all 16 ANSI colors in a neat table.

reset=$(tput sgr0)
whitespace="$(for i in {1..40}; do echo -n ' '; done)"

print_color() {
	local color=$1
	local background=$(tput setab $color)
	printf '%s%02d %s%s%s' $reset $color $background "$whitespace" $reset
}

for color in {0..7}; do
	color_bright=$((color+8))

	printf '%s  %s\n' "$(print_color $color)" "$(print_color $color_bright)"
done
echo $reset
