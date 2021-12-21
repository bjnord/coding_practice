#!/bin/sh -e
#
# Create a `advent-2021/day-<nn>` directory with Mix project under it
# Designed to be reentrant

ADVENTPATH="$HOME/coding_practice/advent-2021"

usage()
{
	echo "Usage: new-day.sh [ -v -x -y ] <nn> <project>" >&2
	echo "	creates/updates \"advent-2021/day-<nn>\" directory and project" >&2
	echo "	-v|--verbose: verbose mode" >&2
	echo "	-x|--remove:  remove prior directory and create fresh" >&2
	echo "	-y|--yes:     implied \"yes\" to all questions" >&2
	exit 64
}
ask_yes()
{
	if [ $IMPLIEDYES -ne 1 ]; then
		echo
		echo -n "** $1? "
		read y
		echo
		if [ "`echo \"$y\" | tr Y y | cut -c1`" != y ]; then
			echo "aborting" >&2
			exit 2
		fi
	fi
}
log()
{
	if [ $VERBOSE -eq 1 ]; then
		echo "$1" >&2
	fi
}

VERBOSE=0
REMOVEDIR=0
IMPLIEDYES=0
while [ -n "$1" ]; do
	case $1 in
		-\?|-h|--help)
			usage
			;;
		-v|--verbose)
			VERBOSE=1
			;;
		-x|--remove)
			REMOVEDIR=1
			;;
		-y|--yes)
			IMPLIEDYES=1
			;;
		*)
			if [ -z "$NN" ]; then
				if [ "`echo \"$1\" | cut -c1`" == - ]; then
					echo "$0: unknown option \"$1\"" >&2
					usage
				else
					NN="$1"
				fi
			else
				PROJECT="`echo \"$1\" | tr A-Z a-z`"
				MODULE="`echo \"$PROJECT\" | perl -pe 's/\b(\w)/\U$1/; s/\s+//;'`"
			fi
			;;
	esac
	shift
done
if [ -z "`echo \"$NN\" | cut -c2`" ]; then
	echo "$0: day number missing or less than 2 digits" >&2
	usage
elif [ -z "$PROJECT" ]; then
	echo "$0: project name missing" >&2
	usage
fi
log "MODULE=$MODULE VERBOSE=$VERBOSE REMOVEDIR=$REMOVEDIR IMPLIEDYES=$IMPLIEDYES" >&2

DAYPATH="$ADVENTPATH/day-$NN"
if [ $REMOVEDIR -eq 1 -a -d $DAYPATH ]; then
	ask_yes "Are you SURE you want to remove existing $DAYPATH"
	log "removing existing $DAYPATH"
	rm -rf $DAYPATH
fi

if [ ! -d $DAYPATH ]; then
	log "creating $DAYPATH REMOVEDIR=$REMOVEDIR IMPLIEDYES=$IMPLIEDYES" >&2
	mkdir -p $DAYPATH
fi
cd $DAYPATH

if [ ! -d $PROJECT ]; then
	log "creating mix project $PROJECT" >&2
	mix new $PROJECT
fi
cd ./$PROJECT
if [ -f README.md ]; then
	log "removing README.md" >&2
	rm -f README.md
fi
mkdir -p config
for c in config dev test prod; do
	CONFIG="config/$c.exs"
	if [ ! -f $CONFIG ]; then
		log "copying $CONFIG from day-05/hydrothermal"
		cp "$ADVENTPATH/day-05/hydrothermal/$CONFIG" $CONFIG
	fi
done
if [ -z "`grep escript mix.exs`" ]; then
	log "copying mix.exs from day-06/lanternfish (for escript and deps)"
	perl -pe "s/lanternfish/$PROJECT/g; s/Lanternfish/$MODULE/g;" "$ADVENTPATH/day-06/lanternfish/mix.exs" >mix.exs
fi
if [ ! -d deps ]; then
	log "getting dependencies"
	mix deps.get
fi
if [ ! -f Makefile ]; then
	log "copying Makefile from day-05/hydrothermal"
	perl -pe "s/hydrothermal/$PROJECT/g; s/Hydrothermal/$MODULE/g;" "$ADVENTPATH/day-05/hydrothermal/Makefile" >Makefile
fi
if [ ! -f log/.keep ]; then
	log "creating log/.keep"
	mkdir -p log
	touch log/.keep
fi
if [ -n "`grep 'Ignore package tarball' .gitignore`" ]; then
	log "adding /$PROJECT to .gitignore"
	perl -pe "s/Ignore package tarball.*/Ignore compiled binary./; s@.*-\*\.tar.*@/$PROJECT@g;" -i .gitignore
fi
if [ -z "`grep 'Ignore logfiles' .gitignore`" ]; then
	log "adding /log/ to .gitignore"
	echo "# Ignore logfiles." >>.gitignore
	echo "/log/" >>.gitignore
	echo "" >>.gitignore
fi
if [ ! -d input ]; then
	log "creating input"
	mkdir input
	touch input/input.txt
fi
PARSER="lib/$PROJECT/parser.ex"
if [ ! -f $PARSER ]; then
	log "copying $PARSER from day-09/smoke"
	mkdir -p "lib/$PROJECT"
	SOURCE="`echo \"$ADVENTPATH/day-09/smoke/$PARSER\" | sed \"s/$PROJECT/smoke/\"`"
	perl -pe "s/smoke/$PROJECT/g; s/Smoke/$MODULE/g;" $SOURCE >$PARSER
fi
PARSERTEST="test/$PROJECT/parser_test.exs"
if [ ! -f $PARSERTEST ]; then
	log "copying $PARSERTEST from day-09/smoke"
	mkdir -p "test/$PROJECT"
	SOURCE="`echo \"$ADVENTPATH/day-09/smoke/$PARSERTEST\" | sed \"s/$PROJECT/smoke/\"`"
	perl -pe "s/smoke/$PROJECT/g; s/Smoke/$MODULE/g;" $SOURCE >$PARSERTEST
fi

cat >/tmp/main_parts$$ <<MAIN_PARTS

  alias $MODULE.Parser, as: Parser
  alias Submarine.CLI, as: CLI

  @doc """
  Parse arguments and call puzzle part methods.

  ## Parameters

  - argv: Command-line arguments
  """
  def main(argv) do
    {input_file, opts} = CLI.parse_args(argv)
    if Enum.member?(opts[:parts], 1), do: part1(input_file)
    if Enum.member?(opts[:parts], 2), do: part2(input_file)
  end

  @doc """
  Process input file and display part 1 solution.
  """
  def part1(input_file) do
    File.read!(input_file)
    |> Parser.parse()
    nil  # TODO
    |> IO.inspect(label: "Part 1 answer is")
  end

  @doc """
  Process input file and display part 2 solution.
  """
  def part2(input_file) do
    File.read!(input_file)
    |> Parser.parse()
    nil  # TODO
    |> IO.inspect(label: "Part 2 answer is")
  end
end
MAIN_PARTS
MAIN="lib/$PROJECT.ex"
if [ -z "`grep 'def main' $MAIN`" ]; then
	log "adding main() to $MAIN"
	( grep -v '^end' $MAIN ; cat /tmp/main_parts$$ ) >>/tmp/newday_main$$
	mv /tmp/newday_main$$ $MAIN
fi
rm -f /tmp/main_parts$$

exit 0
