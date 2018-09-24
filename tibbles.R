library(tidyverse)
library(tibble)

# CREATING
# tibble

# never changes an input's type - no more stringsAsFactors = FALSE
tibble(x = letters)

#data_frame is an alias
data_frame(x = letters)

# makes it easirer to use with list-columns
tibble(x = 1:3, y = list(1:5, 1:10, 1:20))
# List columns are typically created by dplyr::do()

# It never adjusts the names of variables
names(data.frame(`crazy name` = 1))
names(tibble(`crazy name` = 1))

# it evaluates arguments lazily and sequentially
tibble(x = 1:5, y = x ^ 2)

# arguments are processed with rlang::quos()
# and support unquote via !! and unquote-splice via !!!.
tibble(!!! list(x = rlang::quo(1:10), y = quote(x * 2)))

# it never use row.names(). The whole point of tidy data is to store variables in a consistent way. 
# So it never stores a variable as special attribute

# It only recycles vectors of length 1. 
# This is because recycling vectors of greater lengths is a frequent source of bugs


# tribble
# Create tibbles using an easier to read row-by-row layout
# Variable names should be formulas, and may only appear before the data.
tribble(
  ~colA, ~colB,
  "a",   1,
  "b",   2,
  "c",   3
)

# tribble will create a list column if the value in any cell is not a scalar
tribble(
  ~x, ~y,
  "a", 1:3,
  "b", 4:6
)


# COERCION

# as_tibble coerces objects into tibbles
df <- data.frame(x = 1:2, y = 3:4)
as_tibble(df)

l <- list(x = 1:2, y = 3:4)
as_tibble(l)


# TIBBLES VS DATA FRAMES
# There are 3 key differences: printing, subsetting and recycling

# printing - only show first 10 rows
df <- tibble(x = 1:1000)
df

# if there are more than n rows, only print the first m rows
options(tibble.print_max = 10, tibble.print_min = 5)
df
df <- tibble(x = 1:7)
df
df <- tibble(x = 1:15)
df

# subsetting - [ always returns another tibble
df1 <- data.frame(x = 1:3, y = 3:1)
class(df1[, 1:2])
class(df1[, 1])

df2 <- tibble(x = 1:3, y = 3:1)
class(df2[, 1:2])
class(df2[, 1])

# to extract a single column use [[ or $
class(df2[[1]])
class(df2$x)

# Tibbles are also stricter with $. Tibbles never do partial matching, 
# and will throw a warning and return NULL if the column does not exist:
df <- data.frame(abc = 1)
df$a

df2 <- tibble(abc = 1)
df2$a

# recycling
# When constructing a tibble, only values of length 1 are recycled. 
# The first column with length different to one determines the number of rows in the tibble, 
# conflicts lead to an error. 
# This also extends to tibbles with zero rows, which is sometimes important for programming:
tibble(a = 1, b = 1:3)
tibble(a = 1:3, b = 1)
tibble(a = 1:3, c = 1:2) # error
tibble(a = 1, b = integer()) # no rows
tibble(a = integer(), b = 1) # no rows


# add_column
# add_column(.data, ..., .before = NULL, .after = NULL)
# ... Name-value pairs, passed on to tibble()
# .before, .after
# One-based column index or column name where to add the new columns, default: after last column.

df <- tibble(x = 1:3, y = 3:1)
add_column(df, z = -1:1, w = 0)

# you can't overwrite existing columns
add_column(df, x = 4:6) # error

# You can't create new observations
add_column(df, z = 1:5)

# .after
add_column(df, z = -1:1, w = 0, .after = "x")

# Quasiquotation
l <- list(z = -1:1, w = 0)
add_column(df, l) # error, data must have 3 rows
add_column(df, !!!l)

z <- -1:1
expr_z <- enquo(z)
add_column(df, z = !!z)


# add_row
# add_row(.data, ..., .before = NULL, .after = NULL)
# ... Name-value pairs, passed on to tibble()
# .before, .after
# One-based row index or column name where to add the new columns, default: after last row.
# add_case() is an alias of add_row()

df <- tibble(x = 1:3, y = 3:1)
add_row(df, x = 4, y = 0)

add_row(df, x = 4, y = 0, .before = 2)

# You can supply vectors, to add multiple rows
add_row(df, x = 4:5, y = 0:-1)

# quasiquotation
l <- list(x = 4:5, y = 0:-1)
add_row(df, !!!l)

# Absent variables get missing values
add_row(df, x = 4)

# You can't create new variables
add_row(df, z = 10)


# enframe
# enframe() converts named atomic vectors or lists to two-column data frames. For unnamed vectors,
# the natural sequence is used as name column

# enframe(x, name = "name", value = "value")
# deframe(x)
enframe(1:3)
enframe(c(a = 5, b = 7, c = 9))

deframe(df)

df2 <- enframe(c(a = 5, b = 7, c = 9)) 
deframe(df2)

df3 <- tibble(x = 1:3, z = -1:1, y = 3:1)
df3
deframe(df3) # appears that extra columns are ignored



## frame_matrix
## Create matrices laying out the data in rows, similar to matrix(..., byrow = TRUE), 
# with a nicerto-read syntax. 
frame_matrix(
  ~col1, ~col2,
  1, 3,
  5, 2
)

# same as
matrix(c(1,3,5,2), nrow = 2, byrow = TRUE, dimnames = list(NULL, c("col1", "col2")))


# glimpse
#This is like a transposed version of print(): columns run down the page, and data runs across.
# This makes it possible to see every column in a data frame. I
# x original x is (invisibly) returned, allowing glimpse() to be used within a data pipe line
# glimpse is an S3 generic with a customised method for tbls and data.frames, and a default
# method that calls str().
glimpse(mtcars)


# is_tibble
# TRUE if the object inherits from the tbl_df class
is_tibble(df)
is_tibble(1:3)



# new_tibble
# Creates a subclass of a tibble. 
# This function is mostly useful for package authors that implement subclasses of a tibble,
# new_tibble(x, ..., nrow = NULL, subclass = NULL)
new_tibble(list(a = 1:3, b = 4:6))
ndf <- new_tibble(list(), nrow = 150, subclass = "my_tibble")
ndf <- new_tibble(df, subclass = "my_tibble")
str(ndf)


# rownames
# While a tibble can have row names (e.g., when converting from a regular data frame), they are removed
# when subsetting with the [ operator. A warning will be raised when attempting to assign
# non-NULL row names to a tibble. Generally, it is best to avoid row names, because they are basically
# a character column with different semantics to every other column.
has_rownames(mtcars)
has_rownames(iris)
has_rownames(remove_rownames(mtcars))
head(rownames_to_column(mtcars))

mtcars_tbl <- as_tibble(rownames_to_column(mtcars))
mtcars_tbl
as_tibble(rowid_to_column(mtcars)) # integer idx, removes rownames

column_to_rownames(as.data.frame(mtcars_tbl))


# lst
# lst() is similar to list(), but like tibble(), it evaluates its arguments lazily and in order, and
# automatically adds names.
lst(n = 5, x = runif(n))
lst(!!! list(n = rlang::quo(2 + 3), y = quote(runif(n))))



# set_tidy_names() ensures its input has non-missing and unique names (duplicated names get a
# suffix of the format ..# where # is the position in the vector). Valid names are left unchanged, with
# the exception that existing suffixes are reorganized.
# tidy_names() is the workhorse behind set_tidy_names(), it treats the argument as a string to be
# used to name a data frame or a vector.
# set_tidy_names(x, syntactic = FALSE, quiet = FALSE)
# tidy_names(name, syntactic = FALSE, quiet = FALSE)
set_tidy_names(3:5)
set_tidy_names(list(3, 4, 5))
set_tidy_names(mtcars) # left unchanged

tbl <- as_tibble(structure(list(3, 4, 5), class = "data.frame"), validate = FALSE)
tbl
set_tidy_names(tbl)

tidy_names("a b", syntactic = TRUE)



# tbl_sum
# tbl_sum() gives a brief textual description of a table-like object, which should include the dimensions,
# the data source, and possible grouping (for dplyr).
tbl_sum(df)
df
df2 <- group_by(df, x)
df2
tbl_sum(df2)
