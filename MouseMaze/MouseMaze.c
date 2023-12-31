//-----------------------------------------
// This program simulates a mouse in a given maze.
// the mouse will try all paths available to it until
// it reaches the exit or has no more paths to follow,
// then tells the user whether the mouse escaped or not.
//
// takes fomatted input file as piped input
//-----------------------------------------
#include <stdio.h>
#include <stdlib.h>
#include <assert.h>

//-------------------------------------------------------------------------------------
// CONSTANTS and TYPES
//-------------------------------------------------------------------------------------

#define MAX_DIMENSION 20

// constant definitions for the different cell states
const char WALL = '1';
const char SPACE = '0';
const char VISITED = '.';
const char MOUSE = 'm';
const char EXIT = 'e';

typedef enum BOOL { false, true } Boolean;

struct CELL
{
    int row;
    int column;
};
typedef struct CELL Cell;

typedef struct CELL_NODE CellNode;
struct CELL_NODE
{
    Cell     cell;
    CellNode* next;
};

//-------------------------------------------------------------------------------------
// VARIABLES
//-------------------------------------------------------------------------------------

CellNode* top = NULL;

// a 2D array used to store the maze
char maze[MAX_DIMENSION][MAX_DIMENSION];
int mazeRows;
int mazeCols;

// holds the location of the mouse and escape hatch
Cell mouse;
Cell escape;

//-------------------------------------------------------------------------------------
// PROTOTYPES
//-------------------------------------------------------------------------------------

// basic cell manipulation

// returns true if the cells are at the same position in our maze
Boolean equalCells(const Cell cell1, const Cell cell2);
// returns a new cell object
Cell makeCell(const int row, const int col);
// returns true if the cell is within our maze
Boolean validCell(const Cell theCell);

// routines for managing our backtracking

// returns true if there are no more cells to try
Boolean noMoreCells();
// returns the next cell to try for a path out of the maze
Cell nextCell();
// introduces a new cell to try
void addCell(const Cell cell);

void printMaze();
void loadMaze();

// returns true if there's a solution to the maze
Boolean solveMaze();

// our invariant checker
void checkState();

//-------------------------------------------------------------------------------------
// FUNCTIONS
//-------------------------------------------------------------------------------------

int main(int argc, char* argv[])
{
    loadMaze();

    if (solveMaze())
        printf("The mouse is free!!!!\n");
    else
        printf("The mouse is trapped!!!!\n");

    printf("\nEnd of processing\n");

    return EXIT_SUCCESS;
}


//////////////////////////////////////////////
// Cell routines
//////////////////////////////////////////////

//------------------------------------------------------
// equalCells
//
// PURPOSE: determines if two cells share the same position.
// INPUT PARAMETERS:
// cell1, cell2 - the two cells to compare
// OUTPUT PARAMETERS:
// Returns true if the cells have matching positions,
// false if not
//------------------------------------------------------
Boolean equalCells(const Cell cell1, const Cell cell2)
{
    //pre
    assert(validCell(cell1) && validCell(cell2));
    Boolean same = false;

    if (validCell(cell1) && validCell(cell2))
    {
        if (cell1.row == cell2.row && cell1.column == cell2.column)
            same = true;

        //post
        assert(same == (cell1.row == cell2.row && cell1.column == cell2.column));
    }
    else
    {
        fprintf(stderr, "Invalid cell(s) passed to equalCells.\n");
    }

    return same;
}

//------------------------------------------------------
// makeCell
//
// PURPOSE: creates a new cell using the given parameters,
// then return it
// INPUT PARAMETERS:
// row - what row to assign to the new cell
// col - what coloumn to assign to the new cell
// OUTPUT PARAMETERS:
// Returns the created cell which has its row and coloumn
// set to the supplied values, respectively.
//------------------------------------------------------
Cell makeCell(const int row, const int col)
{
    //pre
    assert(row >= 0 && row < mazeRows&& col >= 0 && col < mazeCols);

    Cell newCell;

    if (row >= 0 && row < mazeRows && col >= 0 && col < mazeCols)
    {
        // assign the values
        newCell.row = row;
        newCell.column = col;

        //post
        assert(&newCell != NULL && validCell(newCell));
    }
    else
    {
        newCell.row = -1;
        newCell.column = -1;
        fprintf(stderr, "The row and/or coloumn passed to makeCell was out of bounds of the maze.\n");
    }

    return newCell;
}

//------------------------------------------------------
// validCell
//
// PURPOSE: this function checks that a given cell is
// within the bounds of the maze
// INPUT PARAMETERS:
// theCell - the cell to check if within bounds
// OUTPUT PARAMETERS:
// Returns true of theCell is within the bounds of the maze
// false if not.
//------------------------------------------------------
Boolean validCell(const Cell theCell)
{
    //pre
    Boolean isValid = false;

    //determine if in bounds
    assert(theCell.row >= 0 && theCell.row < mazeRows&& theCell.column >= 0 && theCell.column < mazeCols);

    if (theCell.row >= 0 && theCell.row < mazeRows && theCell.column >= 0 && theCell.column < mazeCols)
    {
        isValid = true;
        //post
        assert(isValid && (theCell.row >= 0 && theCell.row < mazeRows&& theCell.column >= 0 && theCell.column < mazeCols));
    }
    else
    {
        fprintf(stderr, "cell passed to validCell was not in bounds if the maze.\n");
    }


    return isValid;
}

//////////////////////////////////////////////
// List routines
//////////////////////////////////////////////

//------------------------------------------------------
// noMoreCells
//
// PURPOSE: determines if there are any nodes left in the
// stack.
// OUTPUT PARAMETERS:
// Returns true if the stack is empty, false if not
//------------------------------------------------------
Boolean noMoreCells()
{
    //pre
    assert(top == NULL || validCell(top->cell));

    Boolean noCellsLeft = false;

    if (top == NULL || validCell(top->cell))
    {
        noCellsLeft = (top == NULL);

        //post
        assert(noCellsLeft == (top == NULL));
    }
    else
    {
        fprintf(stderr, "top cell is not a valid cell.\n");
    }

    return noCellsLeft;
}

//------------------------------------------------------
// nextCell
//
// PURPOSE: removes and returns the cell at the top of the
// stack, shifting so the next cell is on top.
// OUTPUT PARAMETERS:
// Returns the cell that was ontop of the stack
//------------------------------------------------------
Cell nextCell()
{
    //pre
    assert(!noMoreCells());
    Cell next;

    if (!noMoreCells())
    {
        //pop the stack
        CellNode* temp;

        temp = top;
        next = temp->cell;
        top = top->next;

        //post
        assert(top == NULL || validCell(top->cell));
        assert(&next != NULL);

        free(temp); //free the node
    }
    else
    {
	next = makeCell(1,1);
        fprintf(stderr, "nextCell was called when the stack was empty.\n");
    }

    return next;
}

//------------------------------------------------------
// addCell
//
// PURPOSE: this function adds a cell to the stack
// INPUT PARAMETERS:
// cell - cell to add to the stack
// OUTPUT PARAMETERS:
// a cell is added to the top of the stack (as a cellnode)
//------------------------------------------------------
void addCell(const Cell cell)
{
    //pre
    assert(validCell(cell));

    if (validCell(cell))
    {
        //dont add to stack if already there (this isnt an error, just a special case)
        CellNode* comp = top;
        Boolean alreadyAdded = false;
        while (comp != NULL && !alreadyAdded)
        {
            if (equalCells(cell, comp->cell))
                alreadyAdded = true;
            comp = comp->next;
        }

        if (!alreadyAdded)
        {
            //add to stack
            CellNode* temp;
            temp = malloc(sizeof(CellNode));

            assert(temp != NULL);
            if (temp != NULL)
            {
                temp->cell = cell;
                temp->next = top;

                top = temp;

                //post
                assert(top != NULL && equalCells(cell, top->cell));
            }
            else
            {
                fprintf(stderr, "Dynamic Memory Allocation for struct failed.\n");
            }
        }
    }
    else
    {
        fprintf(stderr, "addCell was given a NULL pointer or an invalid cell.\n");
    }
}

//////////////////////////////////////////////
// Maze routines
//////////////////////////////////////////////
//------------------------------------------------------
// printMaze
//
// PURPOSE: prints the current maze
//------------------------------------------------------
void printMaze()
{
    //pre
    assert(mazeRows > 0 && mazeRows <= MAX_DIMENSION && mazeCols > 0 && mazeCols <= MAX_DIMENSION);
    if (mazeRows > 0 && mazeRows <= MAX_DIMENSION && mazeCols > 0 && mazeCols <= MAX_DIMENSION)
    {
        for (int i = 0; i < mazeRows; i++)
        {
            for (int j = 0; j < mazeCols; j++)
            {
                printf("%c", maze[i][j]);
                if (j == mazeCols - 1)
                    printf("\n");
                else
                    printf(" ");
            }
        }
    }
    else
    {
        fprintf(stderr, "mazeRows and/or mazeCols are out of bounds. Did not print maze.");
    }
}

//------------------------------------------------------
// loadMaze
//
// PURPOSE: this function loads a maze given from stdin.
// OUTPUT PARAMETERS:
// maze will be filled with the given values in stdin.
//------------------------------------------------------
void loadMaze()
{
    //load the maze from standard input

    //get the height/width
    int result = scanf("%d %d", &mazeRows, &mazeCols);

    //pre
    assert(result == 2 && mazeRows <= MAX_DIMENSION && mazeCols <= MAX_DIMENSION && mazeRows > 0 && mazeCols > 0);

    //attempt to load the maze
    if (result == 2 && mazeRows <= MAX_DIMENSION && mazeCols <= MAX_DIMENSION && mazeRows > 0 && mazeCols > 0)
    {
        //get rest of maze
        for (int i = 0; i < mazeRows; i++)
        {
            for (int j = 0; j < mazeCols; j++)
            {
                getchar();  //ignore space or newline
                maze[i][j] = getchar();

                //assign mouse/exit if applicable
                if (maze[i][j] == MOUSE)
                    mouse = makeCell(i, j);

                if (maze[i][j] == EXIT)
                    escape = makeCell(i, j);

                if (maze[i][j] != WALL && maze[i][j] != SPACE && maze[i][j] != VISITED && maze[i][j] != MOUSE && maze[i][j] != EXIT)
                {
                    fprintf(stderr, "Invalid character '%c' in the maze.\n", maze[i][j]);
                }
            }
        }
    }
    else
    {
        fprintf(stderr, "There was a problem getting the size of the maze.  Ensure it is in the right format, and a valid size.\n");
    }

    //post
    checkState();

    //check that the maze has walls around it
    Boolean hasWalls = true;
    for (int i = 0; i < mazeCols && hasWalls; i++)
    {
        if (maze[0][i] != WALL || maze[mazeRows - 1][i] != WALL)
        {
            hasWalls = false;
            fprintf(stderr, "The given maze does not have walls around its edges.\n");
        }
    }
    for (int i = 0; i < mazeRows && hasWalls; i++)
    {
        if (maze[i][0] != WALL || maze[i][mazeCols - 1] != WALL)
        {
            hasWalls = false;
            fprintf(stderr, "The given maze does not have walls around its edges.\n");
        }
    }

    assert(hasWalls);
}

//------------------------------------------------------
// solveMaze
//
// PURPOSE: this function drives the solving of the maze
// by adding open spaces to the stack and exploring based
// on that stack until either the exit is found or the
// stack is empty.
// OUTPUT PARAMETERS:
// Returns true if the maze can be escaped, false if not
//------------------------------------------------------
Boolean solveMaze()
{
    Boolean solvable = true;

    //pre
    checkState();

    if (validCell(mouse) && validCell(escape))
    {
        Cell currentCell = mouse;

        //print starting maze
        printMaze();
        printf("\n");

        while (!equalCells(currentCell, escape) && solvable)
        {
            assert(validCell(currentCell));
            if (validCell(currentCell))
            {
                //mark currentCell as visited
                maze[currentCell.row][currentCell.column] = VISITED;

                //add open neighbours
                if (maze[currentCell.row - 1][currentCell.column] != WALL && maze[currentCell.row - 1][currentCell.column] != VISITED)
                {
                    addCell(makeCell(currentCell.row - 1, currentCell.column));

                    assert(validCell(top->cell));
                    if (!validCell(top->cell))
                        fprintf(stderr, "currentCell's neighbour is invalid.\n");
                }
                if (maze[currentCell.row][currentCell.column + 1] != WALL && maze[currentCell.row][currentCell.column + 1] != VISITED)
                {
                    addCell(makeCell(currentCell.row, currentCell.column + 1));

                    assert(validCell(top->cell));
                    if (!validCell(top->cell))
                        fprintf(stderr, "currentCell's neighbour is invalid.\n");
                }
                if (maze[currentCell.row + 1][currentCell.column] != WALL && maze[currentCell.row + 1][currentCell.column] != VISITED)
                {
                    addCell(makeCell(currentCell.row + 1, currentCell.column));

                    assert(validCell(top->cell));
                    if (!validCell(top->cell))
                        fprintf(stderr, "currentCell's neighbour is invalid.\n");
                }
                if (maze[currentCell.row][currentCell.column - 1] != WALL && maze[currentCell.row][currentCell.column - 1] != VISITED)
                {
                    addCell(makeCell(currentCell.row, currentCell.column - 1));

                    assert(validCell(top->cell));
                    if (!validCell(top->cell))
                        fprintf(stderr, "currentCell's neighbour is invalid.\n");
                }

                if (noMoreCells())
                {//list empty, cant be solved
                    solvable = false;
                }
                else
                {//still spots to check
                    currentCell = nextCell();
                }

                printMaze();
                printf("\n");

                checkState();
            }
            else
            {
                fprintf(stderr, "currentCell is not a valid cell.\n");
            }
        }
	
	//free rest of stack if not empty
	while(!noMoreCells())
		nextCell();
        //post
        assert((solvable && validCell(currentCell) && equalCells(currentCell, escape)) ||
            (!solvable && validCell(currentCell) && !equalCells(currentCell, escape) && noMoreCells()));
        assert(noMoreCells());
	checkState();
    }
    else
    {
        fprintf(stderr, "Starting position or Exit position is invalid.\n");
    }

    return solvable;
}

//------------------------------------------------------
// checkState
//
// PURPOSE: check the invariant of the program
//------------------------------------------------------
void checkState()
{
    assert((top == NULL) == noMoreCells());
    assert(mazeRows <= MAX_DIMENSION && mazeRows > 0 && mazeCols <= MAX_DIMENSION && mazeCols > 0);
    assert(validCell(mouse) && validCell(escape) && !equalCells(mouse, escape));
}
