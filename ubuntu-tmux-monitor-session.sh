#!/bin/bash

# TMUX System Monitor
#
# Description: A set of Terminal Multiplexed (TMUX) windows and panels making it easier to monitor
#              common system processes, authenticated users, etc.
# Author:      Andre Basson
#
# w/ ref. https://minimul.com/increased-developer-productivity-with-tmux-part-4.html
#

##FUNCTIONS
 #==============================================================================
 #Funtion addWindow1x1
  #@param: $1 = window name/label of this new window
  #@param: $2 = session name/label to which this new window should be added
  #@param: $3 = default command to execute in each window pane
  #
 function addWindow1x1 () {
   local WIN_LABEL=""
   local SESSION=""
   local COMMAND=""
   local numParms="$#"

   #confirm number of parameters, set local variables, & call a base window function with label "$WIN_LABEL"
   # (or terminate the function and process)
   #
   case $numParms in
     1) if [[ ! -z "$1" ]]
        then
           SESSION="$1"     
         
           #tmux to declare a new window:
           # -a = add window
           # -n = name/label for window
           #
           tmux new-window -t "$SESSION" -a
        fi
        ;;

     2) if [[ (! -z $1 && ! -z $2) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           tmux new-window -t "$SESSION" -a -n "$WIN_LABEL"
        fi
        ;;

     3) if [[ (! -z $1 && ! -z $2 && ! -z $3) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           COMMAND="$3"
           tmux new-window -t "$SESSION" -a -n "$WIN_LABEL"
        fi
        ;;

     *) echo -e "\nFATAL ERROR: Incorrect number of arguments received"
        echo -e "Terminating function and process.\n"
        exit 1
        ;;
   esac

   ##split the (autoselected 0th) window above horizontally (h) into panes p0 & p1
   # eg.:
   #     ----------------------
   #     |          |         |
   #     |          |         |
   #     |          |         |
   #     |    0     |    1    |
   #     |          |         |
   #     |          |         |
   #     |          |         |
   #     ----------------------
   #
   tmux split-window -h

   ##resize the selected pane in direction to the (R)ight by ?? no cells greater (currently 0, ie. panes equal in width)
   # Other directions: D, U, L, R (down/up/left/right)
   #
   tmux resize-pane -R 0

   #OPTIONAL: send default command to all panes in the current window
   #
   local paneNo=0
   local numPanes=$(tmux list-panes | wc -l)
   if [[ ! -z $COMMAND ]]; then
      #iterate over number 0 through 6 by increment of 1
      #for pane in {0..$numPanes..1}; do
      #    #select the pane and send the command to it
      #    tmux select-pane -t "$pane"
      #    tmux send-keys "$COMMAND" C-m
      #done

      while [ $paneNo -lt $numPanes ]; do
        tmux select-pane -t "$paneNo"
        tmux send-keys "$COMMAND" C-m
        paneNo=$(( $paneNo + 1 ))
      done
   fi


   #select (focus) pane 0 before returning
   tmux select-pane -t 0

   return 0
 }

 #Funtion addWindow2x2
  #@param: $1 = window name/label of this new window
  #@param: $2 = session name/label to which this new window should be added
  #@param: $3 = default command to execute in each window pane
  #
 function addWindow2x2 () {
   local WIN_LABEL=""
   local SESSION=""
   local COMMAND=""
   local numParms="$#"

   #confirm number of parameters, set local variables, & call a base window function
   # (or terminate the function and process)
   #
   case $numParms in
     1) if [[ ! -z "$1" ]]
        then
           SESSION="$1"
           addWindow1x1 "$SESSION"
        fi
        ;;

     2) if [[ (! -z $1 && ! -z $2) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           addWindow1x1 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     3) if [[ (! -z $1 && ! -z $2 && ! -z $3) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           COMMAND="$3"
           addWindow1x1 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     *) echo -e "\nFATAL ERROR: Incorrect number of arguments received"
        echo -e "Terminating function and process.\n"
        exit 1
        ;;
   esac


   ##the 1x1 (1pane x 1pane) window created in the CASE statement looks like this:
   #     -----------------------
   #     |          |          |
   #     |          |          |
   #     |          |          |
   #     |    0     |    1     |
   #     |          |          |
   #     |          |          |
   #     |          |          |
   #     -----------------------
   #

   ##select left pane (p0), then split it vertically
   # eg.:
   #     -----------------------
   #     |          |          |
   #     |    0     |          |
   #     |          |          |
   #     |----------|    2     |
   #     |          |          |
   #     |    1     |          |
   #     |          |          |
   #     -----------------------
   #
   tmux select-pane -t 0
   tmux split-window -v


   ##split right pane (p2) vertically as well
   # eg.:
   #     ----------------------
   #     |          |          |
   #     |    0     |    2     |
   #     |          |          |
   #     |----------|----------|
   #     |          |          |
   #     |    1     |    3     |
   #     |          |          |
   #     ----------------------
   #
   tmux select-pane -t 2
   tmux split-window -v

   #OPTIONAL: send default command to all panes in the current window
   #
   local paneNo=0
   local numPanes=$(tmux list-panes | wc -l)
   if [[ ! -z $COMMAND ]]; then
      #iterate over number 0 through 6 by increment of 1
      #for pane in {0..$numPanes..1}; do
      #    #select the pane and send the command to it
      #    tmux select-pane -t "$pane"
      #    tmux send-keys "$COMMAND" C-m
      #done

      while [ $paneNo -lt $numPanes ]; do
        tmux select-pane -t "$paneNo"
        tmux send-keys "$COMMAND" C-m
        paneNo=$(( $paneNo + 1 ))
      done
   fi

   #select pane 0 before returning
   tmux select-pane -t 0

   return 0
 }

 ##Funtion addWindow2x3
  #@param: $1 = window name/label of this new window
  #@param: $2 = session name/label to which this new window should be added
  #@param: $3 = default command to execute in each window pane
  #
 function addWindow2x3 () {
   local WIN_LABEL=""
   local SESSION=""
   local COMMAND=""
   local numParms="$#"

   #confirm number of parameters, set local variables, & call a base window function
   # (or terminate the function and process)
   #
   case $numParms in
     1) if [[ ! -z "$1" ]]
        then
           SESSION="$1"
           addWindow2x2 "$SESSION"
        fi
        ;;

     2) if [[ (! -z $1 && ! -z $2) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           addWindow2x2 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     3) if [[ (! -z $1 && ! -z $2 && ! -z $3) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           COMMAND="$3"
           addWindow2x2 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     *) echo -e "\nFATAL ERROR: Incorrect number of arguments received"
        echo -e "Terminating function and process.\n"
        exit 1
        ;;
   esac

   ##from graph on LHS (vertically) split p2 into p2/p3,
   # so as to result in graph on RHS.
   # eg.:
   #     -----------------------    -----------------------
   #     |          |          |    |          |    2     |
   #     |    0     |     2    |    |    0     |----------|
   #     |          |          |    |          |    3     |
   #     |----------|----------| >> |----------|----------|
   #     |          |          |    |          |          |
   #     |    1     |     3    |    |    1     |    4     |
   #     |          |          |    |          |          |
   #     -----------------------    -----------------------
   #
   tmux select-pane -t 2
   tmux split-window -v

   #OPTIONAL: send default command to all panes in the current window
   #
   local paneNo=0
   local numPanes=$(tmux list-panes | wc -l)
   if [[ ! -z $COMMAND ]]; then
      #iterate over number 0 through 6 by increment of 1
      #for pane in {0..$numPanes..1}; do
      #    #select the pane and send the command to it
      #    tmux select-pane -t "$pane"
      #    tmux send-keys "$COMMAND" C-m
      #done

      while [ $paneNo -lt $numPanes ]; do
        tmux select-pane -t "$paneNo"
        tmux send-keys "$COMMAND" C-m
        paneNo=$(( $paneNo + 1 ))
      done
   fi

   #select pane 0 before returning
   tmux select-pane -t 0

   return 0
 }

 ##Funtion addWindow3x2
  #@param: $1 = window name/label of this new window
  #@param: $2 = session name/label to which this new window should be added
  #@param: $3 = default command to execute in each window pane
  #
 function addWindow3x2 () {
   local WIN_LABEL=""
   local SESSION=""
   local COMMAND=""
   local numParms="$#"

   #confirm number of parameters, set local variables, & call a base window function
   # (or terminate the function and process)
   #
   case $numParms in
     1) if [[ ! -z "$1" ]]
        then
           SESSION="$1"
           addWindow2x2 "$SESSION"
        fi
        ;;

     2) if [[ (! -z $1 && ! -z $2) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           addWindow2x2 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     3) if [[ (! -z $1 && ! -z $2 && ! -z $3) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           COMMAND="$3"
           addWindow2x2 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     *) echo -e "\nFATAL ERROR: Incorrect number of arguments received"
        echo -e "Terminating function and process.\n"
        exit 1
        ;;
   esac

   ##from graph on LHS (vertically) split p0 into p0/p1,
   # so as to result in graph on RHS.
   # eg.:
   #     -----------------------    -----------------------
   #     |          |          |    |    0     |          |
   #     |    0     |     2    |    |----------|    3     |
   #     |          |          |    |    1     |          |
   #     |----------|----------| >> |----------|----------|
   #     |          |          |    |          |          |
   #     |    1     |     3    |    |    2     |    4     |
   #     |          |          |    |          |          |
   #     -----------------------    -----------------------
   #
   tmux select-pane -t 0
   tmux split-window -v

   #OPTIONAL: send default command to all panes in the current window
   #
   local paneNo=0
   local numPanes=$(tmux list-panes | wc -l)
   if [[ ! -z $COMMAND ]]; then
      #iterate over number 0 through 6 by increment of 1
      #for pane in {0..$numPanes..1}; do
      #    #select the pane and send the command to it
      #    tmux select-pane -t "$pane"
      #    tmux send-keys "$COMMAND" C-m
      #done

      while [ $paneNo -lt $numPanes ]; do
        tmux select-pane -t "$paneNo"
        tmux send-keys "$COMMAND" C-m
        paneNo=$(( $paneNo + 1 ))
      done
   fi

   #select pane 0 before returning
   tmux select-pane -t 0

   return 0
 }

 ##Funtion addWindow3x3
  #@param: $1 = window name/label of this new window
  #@param: $2 = session name/label to which this new window should be added
  #@param: $3 = default command to execute in each window pane
  #
 function addWindow3x3 () {
   local WIN_LABEL=""
   local SESSION=""
   local COMMAND=""
   local numParms="$#"

   #confirm number of parameters, set local variables, & call a base window function
   # (or terminate the function and process)
   #
   case $numParms in
     1) if [[ ! -z "$1" ]]
        then
           SESSION="$1"
           addWindow2x2 "$SESSION"
        fi
        ;;

     2) if [[ (! -z $1 && ! -z $2) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           addWindow2x2 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     3) if [[ (! -z $1 && ! -z $2 && ! -z $3) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           COMMAND="$3"
           addWindow2x2 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     *) echo -e "\nFATAL ERROR: Incorrect number of arguments received"
        echo -e "Terminating function and process.\n"
        exit 1
        ;;
   esac

   ##now (vertically) split two bottom panes
   #
   # eg.:
   #     -----------------------    -----------------------
   #     |          |          |    |          |          |
   #     |    0     |     2    |    |    0     |    3     |
   #     |          |          |    |          |          |
   #     |----------|----------| >> |----------|----------|
   #     |          |          |    |    1     |    4     |
   #     |    1     |     3    |    |----------|----------|
   #     |          |          |    |    2     |    5     |
   #     -----------------------    -----------------------
   #
   tmux select-pane -t 1
   tmux split-window -v
   tmux select-pane -t 4
   tmux split-window -v

   #select pane 0 before returning
   tmux select-pane -t 0

   #OPTIONAL: send default command to all panes in the current window
   #
   local paneNo=0
   local numPanes=$(tmux list-panes | wc -l)
   if [[ ! -z $COMMAND ]]; then
      #iterate over number 0 through 6 by increment of 1
      #for pane in {0..$numPanes..1}; do
      #    #select the pane and send the command to it
      #    tmux select-pane -t "$pane"
      #    tmux send-keys "$COMMAND" C-m
      #done

      while [ $paneNo -lt $numPanes ]; do
        tmux select-pane -t "$paneNo"
        tmux send-keys "$COMMAND" C-m
        paneNo=$(( $paneNo + 1 ))
      done
   fi

   return 0
 }

 #Funtion addWindow3x4
  #@param: $1 = window name/label of this new window
  #@param: $2 = session name/label to which this new window should be added
  #@param: $3 = default command to execute in each window pane
  #
 function addWindow3x4 () {
   local WIN_LABEL=""
   local SESSION=""
   local COMMAND=""
   local numParms="$#"

   #confirm number of parameters, set local variables, & call a base window function
   # (or terminate the function and process)
   #
   case $numParms in
     1) if [[ ! -z "$1" ]]
        then
           SESSION="$1"
           addWindow2x2 "$SESSION"
        fi
        ;;

     2) if [[ (! -z $1 && ! -z $2) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           addWindow2x2 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     3) if [[ (! -z $1 && ! -z $2 && ! -z $3) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           COMMAND="$3"
           addWindow2x2 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     *) echo -e "\nFATAL ERROR: Incorrect number of arguments received"
        echo -e "Terminating function and process.\n"
        exit 1
        ;;
   esac

   ##now (vertically) split each the 0th, 2nd & 3rd panes seen on the left graph below
   #
   # eg.:
   #     -----------------------    -----------------------
   #     |          |          |    |    0     |     3    |
   #     |    0     |     2    |    |----------|----------|
   #     |          |          |    |    1     |     4    |
   #     |----------|----------| >> |----------|----------|
   #     |          |          |    |          |     5    |
   #     |    1     |     3    |    |    2     |----------|
   #     |          |          |    |          |     6    |
   #     -----------------------    -----------------------
   #
   tmux select-pane -t 0
   tmux split-window -v
   tmux select-pane -t 3
   tmux split-window -v
   tmux select-pane -t 5
   tmux split-window -v

   #select pane 0 before returning
   tmux select-pane -t 0

   #OPTIONAL: send default command to all panes in the current window
   #
   local paneNo=0
   local numPanes=$(tmux list-panes | wc -l)
   if [[ ! -z $COMMAND ]]; then
      #iterate over number 0 through 6 by increment of 1
      #for pane in {0..$numPanes..1}; do
      #    #select the pane and send the command to it
      #    tmux select-pane -t "$pane"
      #    tmux send-keys "$COMMAND" C-m
      #done

      while [ $paneNo -lt $numPanes ]; do
        tmux select-pane -t "$paneNo"
        tmux send-keys "$COMMAND" C-m
        paneNo=$(( $paneNo + 1 ))
      done
   fi

   return 0
 }

 #Funtion addWindow4x1
  #@param: $1 = window name/label of this new window
  #@param: $2 = session name/label to which this new window should be added
  #@param: $3 = default command to execute in each window pane
  #
 function addWindow4x1 () {
   local WIN_LABEL=""
   local SESSION=""
   local COMMAND=""
   local numParms="$#"

   #confirm number of parameters, set local variables, & call a base window function
   # (or terminate the function and process)
   #
   case $numParms in
     1) if [[ ! -z "$1" ]]
        then
           SESSION="$1"
           addWindow1x1 "$SESSION"
        fi
        ;;

     2) if [[ (! -z $1 && ! -z $2) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           addWindow1x1 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     3) if [[ (! -z $1 && ! -z $2 && ! -z $3) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           COMMAND="$3"
           addWindow1x1 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     *) echo -e "\nFATAL ERROR: Incorrect number of arguments received"
        echo -e "Terminating function and process.\n"
        exit 1
        ;;
   esac

   ##in the CASE statement we created a 1x1 window as shown on the graph below
   # eg.:
   #     -----------------------
   #     |          |          |
   #     |          |          |
   #     |          |          |
   #     |    0     |    1     |
   #     |          |          |
   #     |          |          |
   #     |          |          |
   #     -----------------------
   #

   ##now (vertically) split, in the graph above, the left (0th) pane into panes p0 & p1;
   # and then again panes p0 & p1 into p0/p1 & p2/p3.  The initial pane p1 has now become p4.
   #
   # eg.:
   #     -----------------------    -----------------------
   #     |          |          |    |    0     |          |
   #     |          |          |    |----------|          |
   #     |          |          |    |    1     |          |
   #     |    0     |     1    | >> |----------|     4    |
   #     |          |          |    |    2     |          |
   #     |          |          |    |----------|          |
   #     |          |          |    |    3     |          |
   #     -----------------------    -----------------------
   #
   tmux select-pane -t 0
   tmux split-window -v
   tmux select-pane -t 0
   tmux split-window -v
   tmux select-pane -t 2
   tmux split-window -v

   #OPTIONAL: send default command to all panes in the current window
   #
   local paneNo=0
   local numPanes=$(tmux list-panes | wc -l)
   if [[ ! -z $COMMAND ]]; then
      #iterate over number 0 through 6 by increment of 1
      #for pane in {0..$numPanes..1}; do
      #    #select the pane and send the command to it
      #    tmux select-pane -t "$pane"
      #    tmux send-keys "$COMMAND" C-m
      #done

      while [ $paneNo -lt $numPanes ]; do
        tmux select-pane -t "$paneNo"
        tmux send-keys "$COMMAND" C-m
        paneNo=$(( $paneNo + 1 ))
      done
   fi

   #select pane 0 before returning
   tmux select-pane -t 0

   return 0
 }

 #Funtion addWindow1x4
  #@param: $1 = window name/label of this new window
  #@param: $2 = session name/label to which this new window should be added
  #@param: $3 = default command to execute in each window pane
  #
 function addWindow1x4 () {
   local WIN_LABEL=""
   local SESSION=""
   local COMMAND=""
   local numParms="$#"

   #confirm number of parameters, set local variables, & call a base window function
   # (or terminate the function and process)
   #
   case $numParms in
     1) if [[ ! -z "$1" ]]
        then
           SESSION="$1"
           addWindow1x1 "$SESSION"
        fi
        ;;

     2) if [[ (! -z $1 && ! -z $2) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           addWindow1x1 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     3) if [[ (! -z $1 && ! -z $2 && ! -z $3) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           COMMAND="$3"
           addWindow1x1 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     *) echo -e "\nFATAL ERROR: Incorrect number of arguments received"
        echo -e "Terminating function and process.\n"
        exit 1
        ;;
   esac

   ##in the CASE statement we created a 1x1 window as shown on the graph below
   # eg.:
   #     -----------------------
   #     |          |          |
   #     |          |          |
   #     |          |          |
   #     |    0     |    1     |
   #     |          |          |
   #     |          |          |
   #     |          |          |
   #     -----------------------
   #

   ##now (vertically) split, in the graph above, into panes p1/p2, and then
   # again to result in p1/p2 & p2/4 - ie. the graph on the right below.
   #
   # eg.:
   #     -----------------------    -----------------------
   #     |          |          |    |          |    1     |
   #     |          |          |    |          |----------|
   #     |          |          |    |          |    2     |
   #     |    0     |     1    | >> |    0     |----------|
   #     |          |          |    |          |    3     |
   #     |          |          |    |          |----------|
   #     |          |          |    |          |    4     |
   #     -----------------------    -----------------------
   #
   tmux select-pane -t 1
   tmux split-window -v
   tmux select-pane -t 1
   tmux split-window -v
   tmux select-pane -t 3
   tmux split-window -v

   #OPTIONAL: send default command to all panes in the current window
   #
   local paneNo=0
   local numPanes=$(tmux list-panes | wc -l)
   if [[ ! -z $COMMAND ]]; then
      #iterate over number 0 through 6 by increment of 1
      #for pane in {0..$numPanes..1}; do
      #    #select the pane and send the command to it
      #    tmux select-pane -t "$pane"
      #    tmux send-keys "$COMMAND" C-m
      #done

      while [ $paneNo -lt $numPanes ]; do
        tmux select-pane -t "$paneNo"
        tmux send-keys "$COMMAND" C-m
        paneNo=$(( $paneNo + 1 ))
      done
   fi

   #select pane 0 before returning
   tmux select-pane -t 0

   return 0
 }

 #Funtion addWindow4x2
  #@param: $1 = window name/label of this new window
  #@param: $2 = session name/label to which this new window should be added
  #@param: $3 = default command to execute in each window pane
  #
 function addWindow4x2 () {
   local WIN_LABEL=""
   local SESSION=""
   local COMMAND=""
   local numParms="$#"

   #confirm number of parameters, set local variables, & call a base window function
   # (or terminate the function and process)
   #
   case $numParms in
     1) if [[ ! -z "$1" ]]
        then
           SESSION="$1"
           addWindow1x1 "$SESSION"
        fi
        ;;

     2) if [[ (! -z $1 && ! -z $2) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           addWindow1x1 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     3) if [[ (! -z $1 && ! -z $2 && ! -z $3) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           COMMAND="$3"
           addWindow1x1 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     *) echo -e "\nFATAL ERROR: Incorrect number of arguments received"
        echo -e "Terminating function and process.\n"
        exit 1
        ;;
   esac

   ##in the CASE statement above we created a 1x1 window as shown on the graph below
   # eg.:
   #     -----------------------
   #     |          |          |
   #     |          |          |
   #     |          |          |
   #     |    0     |    1     |
   #     |          |          |
   #     |          |          |
   #     |          |          |
   #     -----------------------
   #

   ##now (vertically) split, in the graph above:
   # - the left (0th) pane into panes p0 & p1, and then those into p0/p1 & p2/p3.
   # - the RHS pane (now p4) into panes p4/p5.
   #
   # eg.:
   #     -----------------------    -----------------------
   #     |          |          |    |    0     |          |
   #     |          |          |    |----------|    4     |
   #     |          |          |    |    1     |          |
   #     |    0     |     1    | >> |----------|----------|
   #     |          |          |    |    2     |          |
   #     |          |          |    |----------|    5     |
   #     |          |          |    |    3     |          |
   #     -----------------------    -----------------------
   #
   tmux select-pane -t 0
   tmux split-window -v
   tmux select-pane -t 0
   tmux split-window -v
   tmux select-pane -t 2
   tmux split-window -v
   tmux select-pane -t 4
   tmux split-window -v

   #OPTIONAL: send default command to all panes in the current window
   #
   local paneNo=0
   local numPanes=$(tmux list-panes | wc -l)
   if [[ ! -z $COMMAND ]]; then
      #iterate over number 0 through 6 by increment of 1
      #for pane in {0..$numPanes..1}; do
      #    #select the pane and send the command to it
      #    tmux select-pane -t "$pane"
      #    tmux send-keys "$COMMAND" C-m
      #done

      while [ $paneNo -lt $numPanes ]; do
        tmux select-pane -t "$paneNo"
        tmux send-keys "$COMMAND" C-m
        paneNo=$(( $paneNo + 1 ))
      done
   fi

   #select pane 0 before returning
   tmux select-pane -t 0

   return 0
 }

 #Funtion addWindow2x4 ()
  #@param: $1 = window name/label of this new window
  #@param: $2 = session name/label to which this new window should be added
  #@param: $3 = default command to execute in each window pane
  #
 function addWindow2x4 () {
   local WIN_LABEL=""
   local SESSION=""
   local COMMAND=""
   local numParms="$#"

   #confirm number of parameters, set local variables, & call a base window function
   # (or terminate the function and process)
   #
   case $numParms in
     1) if [[ ! -z "$1" ]]
        then
           SESSION="$1"
           addWindow1x1 "$SESSION"
        fi
        ;;

     2) if [[ (! -z $1 && ! -z $2) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           addWindow1x1 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     3) if [[ (! -z $1 && ! -z $2 && ! -z $3) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           COMMAND="$3"
           addWindow1x1 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     *) echo -e "\nFATAL ERROR: Incorrect number of arguments received"
        echo -e "Terminating function and process.\n"
        exit 1
        ;;
   esac

   ##in the CASE statement above we created a 1x1 window as shown on the graph below
   # eg.:
   #     -----------------------
   #     |          |          |
   #     |          |          |
   #     |          |          |
   #     |    0     |    1     |
   #     |          |          |
   #     |          |          |
   #     |          |          |
   #     -----------------------
   #

   ##now (vertically) split:
   # - the left (0th) pane into panes p0/p1
   # - the RHS pane (now p2), into panes p2/p3, and then again into p2/p3 & p4/p5
   #
   # eg.:
   #     -----------------------    -----------------------
   #     |          |          |    |          |    2     |
   #     |          |          |    |    0     |----------|
   #     |          |          |    |          |    3     |
   #     |    0     |     1    | >> |----------|----------|
   #     |          |          |    |          |    4     |
   #     |          |          |    |    1     |----------|
   #     |          |          |    |          |    5     |
   #     -----------------------    -----------------------
   #
   tmux select-pane -t 0
   tmux split-window -v
   tmux select-pane -t 2
   tmux split-window -v
   tmux select-pane -t 2
   tmux split-window -v
   tmux select-pane -t 4
   tmux split-window -v

   #OPTIONAL: send default command to all panes in the current window
   #
   local paneNo=0
   local numPanes=$(tmux list-panes | wc -l)
   if [[ ! -z $COMMAND ]]; then
      #iterate over number 0 through 6 by increment of 1
      #for pane in {0..$numPanes..1}; do
      #    #select the pane and send the command to it
      #    tmux select-pane -t "$pane"
      #    tmux send-keys "$COMMAND" C-m
      #done

      while [ $paneNo -lt $numPanes ]; do
        tmux select-pane -t "$paneNo"
        tmux send-keys "$COMMAND" C-m
        paneNo=$(( $paneNo + 1 ))
      done
   fi

   #select pane 0 before returning
   tmux select-pane -t 0

   return 0
 }

 #Funtion addWindow4x3
  #@param: $1 = window name/label of this new window
  #@param: $2 = session name/label to which this new window should be added
  #@param: $3 = default command to execute in each window pane
  #
 function addWindow4x3 () {
   local WIN_LABEL=""
   local SESSION=""
   local COMMAND=""
   local numParms="$#"

   #confirm number of parameters, set local variables, & call a base window function
   # (or terminate the function and process)
   #
   case $numParms in
     1) if [[ ! -z "$1" ]]
        then
           SESSION="$1"
           addWindow2x2 "$SESSION"
        fi
        ;;

     2) if [[ (! -z $1 && ! -z $2) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           addWindow2x2 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     3) if [[ (! -z $1 && ! -z $2 && ! -z $3) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           COMMAND="$3"
           addWindow2x2 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     *) echo -e "\nFATAL ERROR: Incorrect number of arguments received"
        echo -e "Terminating function and process.\n"
        exit 1
        ;;
   esac


   ##now (vertically) split, from graph below on the left each the 0th, 1st, & 2nd window panes
   #
   # eg.:
   #     -----------------------    -----------------------
   #     |          |          |    |    0     |     4    |
   #     |    0     |     2    |    |----------|----------|
   #     |          |          |    |    1     |     5    |
   #     |----------|----------| >> |----------|----------|
   #     |          |          |    |    2     |          |
   #     |    1     |     3    |    |----------|     6    |
   #     |          |          |    |    3     |          |
   #     -----------------------    -----------------------
   #
   tmux select-pane -t 0
   tmux split-window -v
   tmux select-pane -t 2
   tmux split-window -v
   tmux select-pane -t 4
   tmux split-window -v

   #OPTIONAL: send default command to all panes in the current window
   #
   local paneNo=0
   local numPanes=$(tmux list-panes | wc -l)
   if [[ ! -z $COMMAND ]]; then
      #iterate over number 0 through 6 by increment of 1
      #for pane in {0..$numPanes..1}; do
      #    #select the pane and send the command to it
      #    tmux select-pane -t "$pane"
      #    tmux send-keys "$COMMAND" C-m
      #done

      while [ $paneNo -lt $numPanes ]; do
        tmux select-pane -t "$paneNo"
        tmux send-keys "$COMMAND" C-m
        paneNo=$(( $paneNo + 1 ))
      done
   fi

   #select pane 0 before returning
   tmux select-pane -t 0

   return 0
 }

 #Funtion addWindow4x4
  #@param: $1 = window name/label of this new window
  #@param: $2 = session name/label to which this new window should be added
  #@param: $3 = default command to execute in each window pane
  #
 function addWindow4x4 () {
   local WIN_LABEL=""
   local SESSION=""
   local COMMAND=""
   local numParms="$#"

   #confirm number of parameters, set local variables, & call a base window function
   # (or terminate the function and process)
   #
   case $numParms in
     1) if [[ ! -z "$1" ]]
        then
           SESSION="$1"
           addWindow2x2 "$SESSION"
        fi
        ;;

     2) if [[ (! -z $1 && ! -z $2) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           addWindow2x2 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     3) if [[ (! -z $1 && ! -z $2 && ! -z $3) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           COMMAND="$3"
           addWindow2x2 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     *) echo -e "\nFATAL ERROR: Incorrect number of arguments received"
        echo -e "Terminating function and process.\n"
        exit 1
        ;;
   esac

   ##now (vertically) split each of the 2x2 window panes
   #
   # eg.:
   #     -----------------------    -----------------------
   #     |          |          |    |    0     |     4    |
   #     |    0     |     2    |    |----------|----------|
   #     |          |          |    |    1     |     5    |
   #     |----------|----------| >> |----------|----------|
   #     |          |          |    |    2     |     6    |
   #     |    1     |     3    |    |----------|----------|
   #     |          |          |    |    3     |     7    |
   #     -----------------------    -----------------------
   #
   tmux select-pane -t 0
   tmux split-window -v
   tmux select-pane -t 2
   tmux split-window -v
   tmux select-pane -t 4
   tmux split-window -v
   tmux select-pane -t 6
   tmux split-window -v

   #OPTIONAL: send default command to all panes in the current window
   #
   local paneNo=0
   local numPanes=$(tmux list-panes | wc -l)
   if [[ ! -z $COMMAND ]]; then
      #iterate over number 0 through 6 by increment of 1
      #for pane in {0..$numPanes..1}; do
      #    #select the pane and send the command to it
      #    tmux select-pane -t "$pane"
      #    tmux send-keys "$COMMAND" C-m
      #done

      while [ $paneNo -lt $numPanes ]; do
        tmux select-pane -t "$paneNo"
        tmux send-keys "$COMMAND" C-m
        paneNo=$(( $paneNo + 1 ))
      done
   fi

   #select pane 0 before returning
   tmux select-pane -t 0

   return 0
 }

 ##Funtion addWindow8x8
  #@param: $1 = window name/label of this new window
  #@param: $2 = session name/label to which this new window should be added
  #@param: $3 = default command to execute in each window pane
  #
 function addWindow8x8 () {
   local WIN_LABEL=""
   local SESSION=""
   local COMMAND=""
   local numParms="$#"

   #confirm number of parameters, set local variables, & call a base window function
   # (or terminate the function and process)
   #
   case $numParms in
     1) if [[ ! -z "$1" ]]
        then
           SESSION="$1"
           addWindow4x4 "$SESSION"
        fi
        ;;

     2) if [[ (! -z $1 && ! -z $2) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           addWindow4x4 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     3) if [[ (! -z $1 && ! -z $2 && ! -z $3) ]]
        then
           WIN_LABEL="$1"
           SESSION="$2"
           COMMAND="$3"
           addWindow4x4 "$WIN_LABEL" "$SESSION"
        fi
        ;;

     *) echo -e "\nFATAL ERROR: Incorrect number of arguments received"
        echo -e "Terminating function and process.\n"
        exit 1
        ;;
   esac

   ##now (vertically) split each of the 4x4 window panes
   #
   #repeat for each pane (p0...p3) to result in equal sized panes p0, p1,...,p8
   # eg.:
   #     -----------------------    -----------------------
   #     |    0     |     4    |    |----------|----------|
   #     |----------|----------|    |----------|----------|
   #     |    1     |     5    |    |----------|----------|
   #     |----------|----------| >> |----------|----------|
   #     |    2     |     6    |    |----------|----------|
   #     |----------|----------|    |----------|----------|
   #     |    3     |     7    |    |----------|----------|
   #     -----------------------    -----------------------
   #
   tmux select-pane -t 0
   tmux split-window -v
   tmux select-pane -t 2
   tmux split-window -v
   tmux select-pane -t 4
   tmux split-window -v
   tmux select-pane -t 6
   tmux split-window -v
   tmux select-pane -t 8
   tmux split-window -v
   tmux select-pane -t 10
   tmux split-window -v
   tmux select-pane -t 12
   tmux split-window -v
   tmux select-pane -t 14
   tmux split-window -v

   #OPTIONAL: send default command to all panes in the current window
   #
   local paneNo=0
   local numPanes=$(tmux list-panes | wc -l)
   if [[ ! -z $COMMAND ]]; then
      #iterate over number 0 through 6 by increment of 1
      #for pane in {0..$numPanes..1}; do
      #    #select the pane and send the command to it
      #    tmux select-pane -t "$pane"
      #    tmux send-keys "$COMMAND" C-m
      #done

      while [ $paneNo -lt $numPanes ]; do
        tmux select-pane -t "$paneNo"
        tmux send-keys "$COMMAND" C-m
        paneNo=$(( $paneNo + 1 ))
      done
   fi

   #select pane 0 before returning
   tmux select-pane -t 0

   return 0
 }

 ### *********************
 ### **** NOT WORKING ****
 ### *********************
 ##function sendDefaultCommand ()
  #@param: $1 -  default command to apply to all panes accross all windows
  #@param: $2 -  session name
  #
 function sendDefaultCommand () {
   DEBUG_ON=1    #1 equades to 'on', 0 to 'off'

   #confirm parameters received correct (2 no.), then set local variables
   if [[ (-z $1 || -z $2) ]]; then exit 1; fi
   local COMMAND="$1"
   local SESSION="$2"

   (($DEBUG_ON)) && echo -e "COMMAND: $COMMAND \nSESSION: $SESSION"

   #array containing window.pane numbers (eg. 0.0, 0.1, 0.2, 1.0, 1.1 ...etc )
   #
   declare -a WINDOWS=$(tmux list-windows -t "$SESSION" | cut -d ':' -f 1)
   for window in "${WINDOWS[@]}"; do
       tmux select-window -t "$SESSION:$window"
       for pane in {0..32..1}; do
           tmux select-pane -t "$pane"
           tmux send-keys "echo $pane" C-m
       done
   done

   #array containing window.pane numbers (eg. 0.0, 0.1, 0.2, 1.0, 1.1 ...etc )
   #
   #declare -a PANES="$(tmux list-panes -s -t "$SESSION" | cut -d ':' -f 1)"
   #
   #for pane in "${PANES[@]}"; do
   #    (($DEBUG_ON)) && echo -e "pane: $pane"
   #    tmux select-pane -t "$SESSION":"$pane"
   #    tmux send-keys "$COMMAND" C-m
   #done

   #for pane in "${PANES[@]}"; do (($DEBUG_ON)) && echo -e "pane: $pane"; tmux select-pane -t "$SESSION":$pane; tmux send-keys "$COMMAND" C-m; done


   return 0
 } 
# e/o functions

##CODE STARTS HERE
 #==============================================================================
 ##session name: current dir
 SESSION="$(basename $PWD)"

 ##create new session, detach it (d), name it (s) the current dir ($SESSION)
 # '-d' detach from session, so that rest of commands can be applied from BASH.
 # '-2' forces tmux to assume terminal supports 256 colors
 #
 tmux -2 new-session -d -s $SESSION

 #####                   #####
 ##### COMPULSORY WINDOW #####
 #####                   #####
 #
 ##SET UP 0TH WINDOW (index 0): "systems_1"
  #------------------------------------------

  ##rename the auto created window (0th index) of session (t) $SESSION, "systems_1"
  #
  tmux rename-window -t $SESSION:0 system_1


  ##split the (autoselected 0th) window above horizontally (h) into panes p0 & p1
  # eg.:
  #      ----------------------
  #     |          |         |
  #     |          |         |
  #     |          |         |
  #     |    0     |    1    |
  #     |          |         |
  #     |          |         |
  #     |          |         |
  #     ----------------------
  #
  tmux split-window -h

  ##in current window, set focus on left pane (ie. pane 0) in window
  #
  tmux select-pane -t 0

  ##resize the selected pane in direction to the (R)ight by ?? lines greater (currently 0, ie. panes equal in width)
  # Other directions: D, U, L, R (down/up/left/right)
  #
  tmux resize-pane -R 0

  ##split left pane vertically twice - 3no vertical sub-panes in the left pane
  # This will result in pane no.3 and 4
  # eg.:
  #     ----------------------
  #     |          |         |
  #     |    0     |         |
  #     |          |         |
  #     |----------|    3    |
  #     |    1     |         |
  #     |----------|         |
  #     |    2     |         |
  #     ----------------------
  #
  tmux split-window -v
  tmux split-window -v

  ##change focus to pane no.3
  #
  tmux select-pane -t 3

  ##...and split the pane (equally) vertically
  #     ----------------------
  #     |          |         |
  #     |    0     |    3    |
  #     |          |         |
  #     |----------|---------|
  #     |    1     |         |
  #     |----------|    4    |
  #     |    2     |         |
  #     ----------------------
  #
  tmux split-window -v

  ##change focus to pane no.3, and then split it vertically (into panes 3 & 4)
  #     ----------------------
  #     |          |    3    |
  #     |    0     |---------|
  #     |          |    4    |
  #     |----------|---------|
  #     |    1     |         |
  #     |----------|    5    |
  #     |    2     |         |
  #     ----------------------
  #
  tmux select-pane -t 3
  tmux split-window -v

  ##change focus to pane no.5, and then split it vertically (into p5, p6)
  #     ----------------------
  #     |          |    3    |
  #     |    0     |---------|
  #     |          |    4    |
  #     |----------|---------|
  #     |    1     |    5    |
  #     |----------|---------|
  #     |    2     |    6    |
  #     ----------------------
  #
  tmux select-pane -t 5
  tmux split-window -v

  ##select p3 (pane 3), resize downwards by 10 lines greater (than p4, the pane it was split vertically from)
  #     ----------------------
  #     |          |         |
  #     |          |    3    |
  #     |          |         |
  #     |    0     |---------|
  #     |          |    4    |
  #     |----------|---------|
  #     |    1     |    5    |
  #     |----------|---------|
  #     |    2     |    6    |
  #     ----------------------
  #
  #
  tmux select-pane -t 3
  tmux resize-pane -D 5

  ##split pane 6 into 6 and 7 horizontally
  #     ----------------------
  #     |          |         |
  #     |          |    3    |
  #     |          |         |
  #     |    0     |---------|
  #     |          |    4    |
  #     |----------|---------|
  #     |    1     |    5    |
  #     |----------|---------|
  #     |    2     |  6 | 7  |
  #     |          |    |    |
  #     |          |    |    |
  #     ----------------------
  #
  tmux select-pane -t 6
  tmux split-window -h

  ##split pane 7 into 7 and 8 vertically
  #     ----------------------
  #     |          |         |
  #     |          |    3    |
  #     |          |         |
  #     |    0     |---------|
  #     |          |    4    |
  #     |----------|---------|
  #     |    1     |    5    |
  #     |----------|---------|
  #     |    2     |  6 | 7  |
  #     |          |----|----|
  #     |          |    | 8  |
  #     ----------------------
  #  
  tmux select-pane -t 8
  tmux split-window -v

  ##send commands to window & panes with 'send-keys' command
  # SYNTAX:  tmux send-keys -t <"command"> C-m
  #               where C-m signals tmux to execute the command
  #
  # EG.: (NOTE: double quotes for values containing white spaces or illegal characters)
  #
  #     tmux select-window -t <"tmux-session-name">:<"tmux-window-index-or-name">
  #     tmux select-pane -t <"pane-number">
  #     tmux send-keys <"command"> C-m
  #
  # eg2.:    tmux select-window -t default:system_1
  #          tmux select-pane -t 0
  #          tmux send-keys "htop" C-m             #to start htop
  #          tmux send-keys "C-c" C-m              #to send Ctrl-c to terminate htop
  #
  # eg3.:    tmux select-window -t "$SESSION":"system_1"
  #          tmux select-pane -t 6
  #          tmux send-keys ' watch -n 5.0 "ls -alth / | grep -Ei 'log'" ' C-m
  #

  #OPTIONAL: send default command to all panes in the current window
  #
  defComm="cd ~; clear"
  paneNo=0
  numPanes=$(tmux list-panes | wc -l)

  #iterate over all the panes in the current window
  #
  while [ $paneNo -lt $numPanes ]; do
    #select a pane, then send the command to it
    #
    tmux select-pane -t "$paneNo"
    tmux send-keys "$defComm" C-m
    paneNo=$(( $paneNo + 1 ))

  done


  ##Send SPECIFIC commands to panes in window labeled "system_1" (ie. 0th index) of tmux session named $SESSION
  #
  tmux select-window -t "$SESSION":"system_1"; tmux select-pane -t 0; tmux send-keys "htop --sort-key PERCENT_CPU" C-m
  tmux select-window -t "$SESSION":"system_1"; tmux select-pane -t 1; tmux send-keys 'watch -n 60.0 "df -h | grep -Evi 'loop'"' C-m
  tmux select-window -t "$SESSION":"system_1"; tmux select-pane -t 2; tmux send-keys "watch -n 5.0 'w | grep -Evi "andre"'" C-m


  command='watch -n 5.0 "ps -afx -o pid,ppid,cmd | grep -Evi 'watch' | grep -Evi 'grep' | grep -Evi 'color' | grep -Ei 'rsync'"'
  tmux select-window -t "$SESSION":"system_1"; tmux select-pane -t 3; tmux send-keys "$command" C-m 
  
  tmux select-window -t "$SESSION":"system_1"; tmux select-pane -t 4; tmux send-keys "sudo kill -9 PID.num.HERE ***OR*** sudo pkill -s SID.num.HERE" C-m
  tmux select-window -t "$SESSION":"system_1"; tmux select-pane -t 5; tmux send-keys "watch -n 30.0 'sudo ufw status numbered'" C-m
   
  #tmux select-window -t "$SESSION":"system_1"; tmux select-pane -t 6; tmux send-keys "watch -n 5.0 'ss -ant'" C-m
  tmux select-window -t "$SESSION":"system_1"; tmux select-pane -t 6; tmux send-keys "watch -n 10.0 'echo '6. NETWORK INTERFACE CONFIGURATION:'; echo ''; ifconfig -a'" C-m  
  tmux select-window -t "$SESSION":"system_1"; tmux select-pane -t 7; tmux send-keys "watch -n 10.0 'echo '7. NETWORK MANAGER CLI:'; echo ''; nmcli c'" C-m  
  tmux select-window -t "$SESSION":"system_1"; tmux select-pane -t 8; tmux send-keys "watch -n 60.0 'echo '8. SUBNET PORT SCANNER:'; echo ''; nmap -v 192.168.178.0/24 | grep -Ei open'" C-m    
  
 #
 
 #####                   #####
 ##### OPTIONAL WINDOWs  #####
 #####                   #####
 #
 #default command to send to every window to start out with
 defComm="cd ~; clear"

 ##SET UP 1ST WINDOW (index 1): "system_2 - socket stats"
  #----------------------------------------------------------
  windowLabel="system_2_network_stats"
  addWindow3x4 "$windowLabel" "$SESSION" "$defComm"

  ##Send SPECIFIC commands to panes in this window of tmux session named $SESSION
  #
  tmux select-window -t "$SESSION":"system_2_network_stats"; tmux select-pane -t 0; tmux send-keys "watch -n 5.0 'echo '0. NETSTAT STATISTICS'; echo ''; sudo netstat -pnltu'" C-m
  tmux select-window -t "$SESSION":"system_2_network_stats"; tmux select-pane -t 1; tmux send-keys "watch -n 5.0 'echo '1. LIST OPEN FILES'; echo ''; lsof -i'" C-m
  tmux select-window -t "$SESSION":"system_2_network_stats"; tmux select-pane -t 2; tmux send-keys "watch -n 5.0 'echo '2. SOCKET STATISTICS'; echo ''; ss -ant'" C-m     
  #tmux select-window -t "$SESSION":"system_2_network_stats"; tmux select-pane -t 3; tmux send-keys "watch -n 5.0 netstat -pnltu | grep -Ei '(22.*|80|139|443|445|9001|18083|ssh)'" C-m
  tmux select-window -t "$SESSION":"system_2_network_stats"; tmux select-pane -t 3; tmux send-keys "watch -n 60.0 'echo '3. ACTIVE HOSTS:'; echo ''; nmap -sL 192.168.178.0\/24 | grep -Ei fritz'" C-m
  tmux select-window -t "$SESSION":"system_2_network_stats"; tmux select-pane -t 4; tmux send-keys "watch -n 5.0 sudo lsof -i :80" C-m
  tmux select-window -t "$SESSION":"system_2_network_stats"; tmux select-pane -t 5; tmux send-keys "watch -n 5.0 sudo lsof -i :443" C-m  
  tmux select-window -t "$SESSION":"system_2_network_stats"; tmux select-pane -t 6; tmux send-keys "watch -n 5.0 sudo lsof -i :445" C-m  
 #


 ##SET UP 2ND WINDOW (index 2): "system_3"
  #---------------------------------------
  windowLabel="system_3"
  addWindow4x3 "$windowLabel" "$SESSION" "$defComm"

  ##Send SPECIFIC commands to panes in this window of tmux session named $SESSION
  #
  tmux select-window -t "$SESSION":"system_3"; tmux select-pane -t 0; tmux send-keys "watch -n 10.0 systemctl status sshd" C-m
  tmux select-window -t "$SESSION":"system_3"; tmux select-pane -t 1; tmux send-keys "watch -n 10.0 systemctl status postfix" C-m
  tmux select-window -t "$SESSION":"system_3"; tmux select-pane -t 2; tmux send-keys "watch -n 10.0 systemctl status ddclient" C-m
  tmux select-window -t "$SESSION":"system_3"; tmux select-pane -t 3; tmux send-keys "watch -n 2.0 'systemctl status cron'" C-m
  tmux select-window -t "$SESSION":"system_3"; tmux select-pane -t 4; tmux send-keys "watch -n 10.0 systemctl status smbd" C-m
  tmux select-window -t "$SESSION":"system_3"; tmux select-pane -t 5; tmux send-keys "watch -n 10.0 systemctl status openvpn@server.service" C-m
  tmux select-window -t "$SESSION":"system_3"; tmux select-pane -t 6; tmux send-keys "journalctl -f | grep -i -E '(ssh|invalid|closed|disconnected|did not receive|\[preauth\])'" C-m            
 # 
 
 ##SET UP 3RD WINDOW (index 3): "mail"
  #---------------------------------------
  windowLabel="mail"
  addWindow3x2 "$windowLabel" "$SESSION" "$defComm"

  ##Send SPECIFIC commands to panes in this window of tmux session named $SESSION
  #
  tmux select-window -t "$SESSION":"mail"; tmux select-pane -t 0; tmux send-keys "watch -n 30.0 ls -alth /var/mail" C-m
  tmux select-window -t "$SESSION":"mail"; tmux select-pane -t 2; tmux send-keys "watch -n 10.0 ls -alth /mnt/VMs/temp" C-m
  tmux select-window -t "$SESSION":"mail"; tmux select-pane -t 3; tmux send-keys "sudo tail -f /var/mail/root" C-m
  tmux select-window -t "$SESSION":"mail"; tmux select-pane -t 4; tmux send-keys "sudo tail -f /var/mail/andre" C-m
 #

 ##SET UP 4th WINDOW (index 4): "backups" 
  #---------------------------------------  
  windowLabel="backups"
  addWindow4x4 "$windowLabel" "$SESSION" "$defComm"

  ##Send SPECIFIC commands to panes in this window of tmux session named $SESSION
  # NOTE: assumption that Midnight Command (mc) is installed
  # 
  tmux select-window -t "$SESSION":"$windowLabel"; tmux select-pane -t 0; tmux send-keys "cd ~/my_cronjobs/backup-scripts/full-backup_WD500GB_to_WD500GB2; mc" C-m
  tmux select-window -t "$SESSION":"$windowLabel"; tmux select-pane -t 1; tmux send-keys "cd ~/my_cronjobs/backup-scripts/full-backup_mnt-4TB-bkp_to_mnt-4TB-bkp2; mc" C-m
  tmux select-window -t "$SESSION":"$windowLabel"; tmux select-pane -t 2; tmux send-keys "cd ~/my_cronjobs/backup-scripts/full-backup_mnt-VMs; mc" C-m
  tmux select-window -t "$SESSION":"$windowLabel"; tmux select-pane -t 3; tmux send-keys "cd ~/my_cronjobs/backup-scripts/; mc" C-m      
  tmux select-window -t "$SESSION":"$windowLabel"; tmux select-pane -t 4; tmux send-keys "cd ~/my_cronjobs/backup-scripts/incremental-backup_essential-system-files; mc" C-m
  tmux select-window -t "$SESSION":"$windowLabel"; tmux select-pane -t 5; tmux send-keys "cd ~/my_cronjobs/backup-scripts/incremental-backup_home-andre; mc" C-m
  tmux select-window -t "$SESSION":"$windowLabel"; tmux select-pane -t 6; tmux send-keys "cd ~/my_cronjobs/backup-scripts/incremental-backup_mnt-vms-andre\&heidi; mc" C-m
  tmux select-window -t "$SESSION":"$windowLabel"; tmux select-pane -t 7; tmux send-keys "cd ~/my_cronjobs/backup-scripts/; mc" C-m
  
  ##Select (focus) default pane
  tmux select-window -t "$SESSION":"$windowLabel"; tmux select-pane -t 0;
  
 #

 ##SET UP 5TH WINDOW (index 5): "misc1" - no default commands to execute
  #---------------------------------------  
  addWindow4x2 "misc1" "$SESSION" "$defComm"

 ##SET UP 6th WINDOW (index 6): "misc2" - no default commands to execute
  #---------------------------------------
  addWindow4x2 "misc2" "$SESSION" "$defComm"
 #

 #####                 #####
 ##### COMPULSORY CODE #####
 #####                 #####
 #
 ##before exiting this script, we have to execute three more commands:
 #1. make sure that the 0th window is selected in the tmux session $SESSION,
 #2. make sure that the 0th pane is selected in the window in (1), and
 #3. reattach to the detached session
 #
 tmux select-window -t "$SESSION":0
 tmux select-pane -t 0
 tmux attach -t "$SESSION"

 exit 0

## e/o code

##SAMPLE CODE:
 #============================================================================
 ###SET UP 0TH WINDOW (0th index): "systems_1"
 ###------------------------------------------
 #
 ###rename the auto created window (0th index) of session (t) $SESSION, "systems_1"
 ##
 #tmux rename-window -t $SESSION:0 systems_1
 #
 ###split the (autoselected 0th) window above horizontally (h) into panes p0 & p1
 ## eg.:
 ##     ----------------------
 ##     |          |         |
 ##     |          |         |
 ##     |          |         |
 ##     |    0     |    1    |
 ##     |          |         |
 ##     |          |         |
 ##     |          |         |
 ##     ----------------------
 ##
 #tmux split-window -h
 #
 ###in current window, set focus on left pane (ie. pane 0) in window
 ##
 #tmux select-pane -t 0
 #
 ###resize the selected pane in direction to the (R)ight by ?? lines greater (currently 0, ie. panes equal in width)
 ## Other directions: D, U, L, R (down/up/left/right)
 ##
 #tmux resize-pane -R 0
 #
 ###split left pane vertically twice - 3no vertical sub-panes in the left pane
 ## This will result in pane no.3 and 4
 ## eg.:
 ##     ----------------------
 ##     |          |         |
 ##     |    0     |         |
 ##     |          |         |
 ##     |----------|    3    |
 ##     |    1     |         |
 ##     |----------|         |
 ##     |    2     |         |
 ##     ----------------------
 ##
 #tmux split-window -v
 #tmux split-window -v
 #
 ###change focus to pane no.3
 ##
 #tmux select-pane -t 3
 #
 ###...and split the pane (equally) vertically
 ##     ----------------------
 ##     |          |         |
 ##     |    0     |    3    |
 ##     |          |         |
 ##     |----------|---------|
 ##     |    1     |         |
 ##     |----------|    4    |
 ##     |    2     |         |
 ##     ----------------------
 ##
 #tmux split-window -v
 #
 ###change focus to pane no.3, and then split it vertically (into panes 3 & 4)
 ##     ----------------------
 ##     |          |    3    |
 ##     |    0     |---------|
 ##     |          |    4    |
 ##     |----------|---------|
 ##     |    1     |         |
 ##     |----------|    5    |
 ##     |    2     |         |
 ##     ----------------------
 ##
 #tmux select-pane -t 3
 #tmux split-window -v
 #
 ###change focus to pane no.5, and then split it vertically (into p5, p6)
 ##     ----------------------
 ##     |          |    3    |
 ##     |    0     |---------|
 ##     |          |    4    |
 ##     |----------|---------|
 ##     |    1     |    5    |
 ##     |----------|---------|
 ##     |    2     |    6    |
 ##     ----------------------
 ##
 #tmux select-pane -t 5
 #tmux split-window -v
 #
 ###select p3 (pane 3), resize downwards by 10 lines greater (than p4, the pane it was split vertically from)
 ##     ----------------------
 ##     |          |         |
 ##     |          |    3    |
 ##     |          |         |
 ##     |    0     |---------|
 ##     |          |    4    |
 ##     |----------|---------|
 ##     |    1     |    5    |
 ##     |----------|---------|
 ##     |    2     |    6    |
 ##     ----------------------
 ##
 ##
 #tmux select-pane -t 3
 #tmux resize-pane -D 10

 ##default command to send to all panes
 #defCommand="cd ~; clear"

 ###ALL WINDOW TYPES CATERED FOR:
 ## ============================= 
 ##SET UP 1ST WINDOW (index 1): "1x1"
  #----------------------------------
  #windowLabel="1x1"
  #addWindow1x1 "$windowLabel" "$SESSION" "$defComm"

 ##SET UP 2ND WINDOW (index 2): "2x2"
  #----------------------------------
  #windowLabel="2x2"
  #addWindow2x2 "$windowLabel" "$SESSION" "$defComm"

 ##SET UP 3RD WINDOW (index 3): "2x3"
  #----------------------------------
  #windowLabel="2x3"
  #addWindow2x3 "$windowLabel" "$SESSION" "$defComm"

 ##SET UP 4TH WINDOW (index 4): "3x2"
  #----------------------------------
  #windowLabel="3x2"
  #addWindow3x2 "$windowLabel" "$SESSION" "$defComm"

 ##SET UP 5TH WINDOW (index 5): "3x3"
  #----------------------------------
  #windowLabel="3x3"
  #addWindow3x3 "$windowLabel" "$SESSION" "$defComm"

 ##SET UP 6TH WINDOW (index 6): "2x4"
  #----------------------------------
  #windowLabel="2x4"
  #addWindow2x4 "$windowLabel" "$SESSION" "$defComm"

 ##SET UP 7TH WINDOW (index 7): "4x2"
  #----------------------------------
  #windowLabel="4x2"
  #addWindow4x2 "$windowLabel" "$SESSION" "$defComm"

 ##SET UP 8TH WINDOW (index 8): "3x4"
  #----------------------------------
  #windowLabel="3x4"
  #addWindow3x4 "$windowLabel" "$SESSION" "$defComm"

 ##SET UP 9TH WINDOW (index 9): "4x3"
  #----------------------------------
  #windowLabel="4x3"
  #addWindow4x3 "$windowLabel" "$SESSION" "$defComm"

 ##SET UP 10TH WINDOW (index 10): "4x4"
  #--------------------------------------
  #windowLabel="4x4"
  #addWindow4x4 "$windowLabel" "$SESSION" "$defComm"

 ##SET UP 11TH WINDOW (index 11): "4x1"
  #--------------------------------------
  #windowLabel="4x1"
  #addWindow4x1 "$windowLabel" "$SESSION" "$defComm"

 ##SET UP 12TH WINDOW (index 12): "1x4"
  #--------------------------------------
  #windowLabel="1x4"
  #addWindow1x4 "$windowLabel" "$SESSION" "$defComm"

 ##SET UP 13TH WINDOW (index 13): "8x8"
  #----------------------------------
  #windowLabel="8x8"
  #addWindow8x8 "$windowLabel" "$SESSION" "$defComm"

#


