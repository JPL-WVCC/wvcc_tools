FUNCTION Concat, $                      ; Return concatenation of two arrays
   a, $                                 ; First array
   b, $                                 ; Second array
   Dimension=dim                        ; Dimension along which toconcatenate
                                        ; (counting from 0, defaults to *last*
                                        ; dimension of arrays)
;;    Examples:
;;    IDL> Help, Concat(LIndGen(2,3,4), -LIndGen(5,3,4), Dim=0)
;;    <Expression>    LONG      = Array[7, 3, 4]
;;    IDL> Help, Concat(LIndGen(2,3,4), -LIndGen(2,5,4), Dim=1)
;;    <Expression>    LONG      = Array[2, 8, 4]
;;    IDL> Help, Concat(LIndGen(2,3,4), -LIndGen(2,3,5))
;;    <Expression>    LONG      = Array[2, 3, 9]
;;    (use Print with these to see actual results)

;;    Assuming here that a and b are of same dimensions except perhaps for
;;    dimension 'dim', which is assumed to be within range.
;;    Testing and error handling for this is left as an exercise for the
;;    reader. :-)

nDims = Size(a, /N_Dimensions)
IF N_Elements(dim) EQ 0 THEN dim = nDims-1

aDims = Size(a, /Dimensions)
bDims = Size(b, /Dimensions)

;;    Figure out desired dimensions of result

resultDims = aDims
resultDims[dim] = aDims[dim]+bDims[dim]

;;    Make a vector of dimension indices with concatenation dimension *last*

transposeDimOrder = [Where(IndGen(nDims) NE dim), dim]

;;    Juggle dimensions by transposing a and b to put desired concatenation
;;    dimension last, then take all elements together into one vector

joinedVector = [(Transpose(a, transposeDimOrder))[*], $
                (Transpose(b, transposeDimOrder))[*]]

;;    Reform the vector to an array of the right size with juggled dimensions

juggledResult = Reform(Temporary(joinedVector),resultDims[transposeDimOrder])

;;    Un-juggle the dimensions to give final result

Return, Transpose(Temporary(juggledResult), Sort(transposeDimOrder))

END
