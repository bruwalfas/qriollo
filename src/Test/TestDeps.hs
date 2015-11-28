
module Test.TestDeps(test) where

import Test.Testing(TestResult, testOK, testError, testMany)

import ExpressionE
import ExpressionL
import ExpressionK
import Deps(
        Dependency(..), dependencySortL, dependencySortK,
        Graph, graphFromList, dfs, stronglyConnectedComponents, topoSort,
    )

dependencySortLTestCases :: [([DeclarationL], [Dependency DeclarationL])]
dependencySortLTestCases = [
    ([ValueDL 0 (ConstantL $ FixnumC 0)],
     [DpAcyclic (ValueDL 0 (ConstantL $ FixnumC 0))]),

    ([ValueDL 0 (VarL 0)],
     [DpFunctions [ValueDL 0 (VarL 0)]]),

    ([
       ValueDL 0 (ConstantL $ FixnumC 10),
       ValueDL 1 (ConstantL $ FixnumC 11),
       ValueDL 2 (ConstantL $ FixnumC 12)
     ],
     [
       DpAcyclic (ValueDL 0 (ConstantL $ FixnumC 10)),
       DpAcyclic (ValueDL 1 (ConstantL $ FixnumC 11)),
       DpAcyclic (ValueDL 2 (ConstantL $ FixnumC 12))
     ]),

    ([
       ValueDL 0 (LamL 4 $ VarL 1),
       ValueDL 1 (LamL 5 $ VarL 2),
       ValueDL 2 (LamL 6 $ ConstantL $ FixnumC 10)
     ],
     [
       DpFunctions [ValueDL 2 (LamL 6 $ ConstantL $ FixnumC 10)],
       DpFunctions [ValueDL 1 (LamL 5 $ VarL 2)],
       DpFunctions [ValueDL 0 (LamL 4 $ VarL 1)]
     ]),

    ([
       ValueDL 0 (LamL 4 $ VarL 1),
       ValueDL 1 (LamL 5 $ VarL 2),
       ValueDL 2 (LamL 6 $ VarL 0)
     ],
     [
       DpFunctions [
         ValueDL 0 (LamL 4 $ VarL 1),
         ValueDL 2 (LamL 6 $ VarL 0),
         ValueDL 1 (LamL 5 $ VarL 2)
       ]
     ]),

    -- sentinel
    ([ValueDL 0 (ConstantL $ FixnumC 1)],
     [DpAcyclic (ValueDL 0 (ConstantL $ FixnumC 1))])
  ]

dependencySortKTestCases :: [([DeclarationK], [Dependency DeclarationK])]
dependencySortKTestCases = [
    ([
       ValueDK 0 [] (retK (ConstantK $ FixnumC 10)),
       ValueDK 1 [] (retK (ConstantK $ FixnumC 11)),
       ValueDK 2 [] (retK (ConstantK $ FixnumC 12))
     ],
     [
       DpFunctions [
         ValueDK 0 [] (retK (ConstantK $ FixnumC 10))
       ],
       DpFunctions [
         ValueDK 1 [] (retK (ConstantK $ FixnumC 11))
       ],
       DpFunctions [
         ValueDK 2 [] (retK (ConstantK $ FixnumC 12))
       ]
     ]
    ),
    ([
       ValueDK 0 [] (retK (VarK 1)),
       ValueDK 1 [] (retK (VarK 0)),
       ValueDK 2 [] (retK (ConstantK $ FixnumC 12))
     ],
     [
       DpFunctions [
         ValueDK 0 [] (retK (VarK 1)),
         ValueDK 1 [] (retK (VarK 0))
       ],
       DpFunctions [
         ValueDK 2 [] (retK (ConstantK $ FixnumC 12))
       ]
     ]
    ),
    ([
       ValueDK 0 [] (retK (VarK 1)),
       ValueDK 1 [] (retK (VarK 2)),
       ValueDK 2 [] (retK (ConstantK $ FixnumC 12))
     ],
     [
       DpFunctions [
         ValueDK 2 [] (retK (ConstantK $ FixnumC 12))
       ],
       DpFunctions [
         ValueDK 1 [] (retK (VarK 2))
       ],
       DpFunctions [
         ValueDK 0 [] (retK (VarK 1))
       ]
     ]
    ),
    ([
       ValueDK 0 [] (retK (VarK 1)),
       ValueDK 1 [] (retK (VarK 2)),
       ValueDK 2 [] (retK (VarK 0))
     ],
     [
       DpFunctions [
         ValueDK 0 [] (retK (VarK 1)),
         ValueDK 2 [] (retK (VarK 0)),
         ValueDK 1 [] (retK (VarK 2))
       ]
     ]
    ),
    -- sentinel
    ([ValueDK 0 [] (retK (VarK 0))],
     [DpFunctions [ValueDK 0 [] (retK (VarK 0))]])
  ]

dfsTestCases :: [(Graph Int, [Int])]
dfsTestCases = [
  (graphFromList [(0,[4]),(1,[0,4]),(2,[0,1,3]),(3,[0,4]),(4,[3])],
     [0,4,3]),
  (graphFromList [(0,[4]),(1,[1,2,3]),(2,[0,1,3]),(3,[3]),(4,[2,4])],
     [0,4,2,1,3]),
  (graphFromList [(0,[0,1,2,3,4]),(1,[3]),(2,[1]),(3,[0,4]),(4,[1])],
     [0,2,1,3,4]),
  (graphFromList [(0,[0,1,2]),(1,[3]),(2,[1]),(3,[3]),(4,[0,1,2,4])],
     [0,2,1,3]),
  (graphFromList [(0,[4]),(1,[3]),(2,[0,4]),(3,[3]),(4,[0,2])],
     [0,4,2]),
  (graphFromList [(0,[0,1,4]),(1,[1]),(2,[0,4]),(3,[3]),(4,[0,4])],
     [0,4,1]),
  (graphFromList [(0,[0,2,3]),(1,[0,4]),(2,[0,2]),(3,[0,2]),(4,[1])],
     [0,3,2]),
  (graphFromList [(0,[0,1,4]),(1,[1]),(2,[1,2,3]),(3,[3]),(4,[1])],
     [0,4,1]),
  (graphFromList [(0,[4]),(1,[3]),(2,[0,4]),(3,[1]),(4,[0,1,2,4])],
     [0,4,2,1,3]),
  (graphFromList [(0,[2]),(1,[3]),(2,[2,4]),(3,[0,4]),(4,[0,1,2,4])],
     [0,2,4,1,3]),
  (graphFromList [(0,[0]),(1,[1,3,4]),(2,[3]),(3,[1,2,3]),(4,[1])],
     [0]),
  (graphFromList [(0,[0,1,2]),(1,[1]),(2,[2,4]),(3,[3]),(4,[1])],
     [0,2,4,1]),
  (graphFromList [(0,[1,3]),(1,[0,4]),(2,[2,4]),(3,[1,3,4]),(4,[1])],
     [0,3,1,4]),
  (graphFromList [(0,[0]),(1,[0,2]),(2,[1]),(3,[0,4]),(4,[0,1,3])],
     [0]),
  (graphFromList [(0,[2]),(1,[0,1,3]),(2,[0,4]),(3,[3]),(4,[3])],
     [0,2,4,3]),
  (graphFromList [(0,[2,3,4]),(1,[1,2,3]),(2,[2,4]),(3,[1]),(4,[3])],
     [0,2,4,3,1]),
  (graphFromList [(0,[4]),(1,[3]),(2,[0,2]),(3,[2,4]),(4,[0,2])],
     [0,4,2]),
  (graphFromList [(0,[0,1,4]),(1,[3]),(2,[1]),(3,[3]),(4,[3])],
     [0,4,1,3]),
  (graphFromList [(0,[4]),(1,[0,1,3]),(2,[0,4]),(3,[0,4]),(4,[2,4])],
     [0,4,2]),
  (graphFromList [(0,[4]),(1,[0,4]),(2,[0,2,3,4]),(3,[0,4]),(4,[3])],
     [0,4,3]),
  (graphFromList [(0,[0,3,4]),(1,[1]),(2,[3]),(3,[1,3,4]),(4,[0,2])],
     [0,3,4,2,1]),
  (graphFromList [(0,[0,1,2]),(1,[0,4]),(2,[1]),(3,[0,2]),(4,[0,2])],
     [0,1,4,2]),
  (graphFromList [(0,[2]),(1,[0,4]),(2,[0,2]),(3,[2,4]),(4,[1])],
     [0,2]),
  (graphFromList [(0,[2,3,4]),(1,[1]),(2,[1]),(3,[0,4]),(4,[0,4])],
     [0,3,4,2,1]),
  (graphFromList [(0,[1,2,4]),(1,[1]),(2,[2,4]),(3,[0,2]),(4,[2,4])],
     [0,2,4,1]),
  (graphFromList [(0,[0,1,2]),(1,[2,4]),(2,[0,4]),(3,[0,2]),(4,[1])],
     [0,1,2,4]),
  (graphFromList [(0,[4]),(1,[0,4]),(2,[1,2,3]),(3,[1]),(4,[0,2])],
     [0,4,2,3,1]),
  (graphFromList [(0,[0,2,3]),(1,[2,4]),(2,[1,3,4]),(3,[1]),(4,[1])],
     [0,2,3,1,4]),
  (graphFromList [(0,[1,3]),(1,[0,2,3,4]),(2,[1]),(3,[1]),(4,[2,4])],
     [0,1,4,3,2]),
  (graphFromList [(0,[0]),(1,[2,4]),(2,[1,3,4]),(3,[1,3,4]),(4,[3])],
     [0]),
  (graphFromList [(0,[0]),(1,[3]),(2,[0,4]),(3,[1,3,4]),(4,[0,1,3])],
     [0]),
  (graphFromList [(0,[2,3,4]),(1,[0,2]),(2,[0,2]),(3,[3]),(4,[2,4])],
     [0,4,3,2]),
  (graphFromList [(0,[0]),(1,[0,1,3]),(2,[0,2]),(3,[3]),(4,[3])],
     [0]),
  (graphFromList [(0,[0,1,4]),(1,[1]),(2,[1,3,4]),(3,[3]),(4,[0,4])],
     [0,4,1]),
  (graphFromList [(0,[4]),(1,[0,2]),(2,[2,4]),(3,[0,4]),(4,[0,4])],
     [0,4]),
  (graphFromList [(0,[0]),(1,[0,2]),(2,[0,2]),(3,[2,4]),(4,[3])],
     [0]),
  (graphFromList [(0,[0]),(1,[0,1,2,4]),(2,[3]),(3,[1]),(4,[0,1,3])],
     [0]),
  (graphFromList [(0,[0,1,2]),(1,[3]),(2,[0,4]),(3,[0,4]),(4,[0,2])],
     [0,1,3,4,2]),
  (graphFromList [(0,[4]),(1,[3]),(2,[0,2]),(3,[2,4]),(4,[1,3,4])],
     [0,4,1,3,2]),
  (graphFromList [(0,[4]),(1,[0,4]),(2,[1,3,4]),(3,[2,4]),(4,[0,2])],
     [0,4,2,3,1]),
  (graphFromList [(0,[2,3,4]),(1,[1]),(2,[1,2,3]),(3,[3]),(4,[2,4])],
     [0,4,2,3,1]),
  (graphFromList [(0,[2]),(1,[3]),(2,[1,3,4]),(3,[1]),(4,[0,4])],
     [0,2,4,1,3]),
  (graphFromList [(0,[4]),(1,[2,4]),(2,[0,4]),(3,[0,2]),(4,[2,4])],
     [0,4,2]),
  (graphFromList [(0,[2]),(1,[0,1,2,4]),(2,[0,4]),(3,[1]),(4,[2,4])],
     [0,2,4]),
  (graphFromList [(0,[0,1,4]),(1,[1]),(2,[2,4]),(3,[1]),(4,[1])],
     [0,4,1]),
  (graphFromList [(0,[4]),(1,[2,4]),(2,[2,4]),(3,[2,4]),(4,[0,2])],
     [0,4,2]),
  (graphFromList [(0,[0]),(1,[2,4]),(2,[0,4]),(3,[1]),(4,[0,4])],
     [0]),
  (graphFromList [(0,[0]),(1,[0,2]),(2,[1,2,3]),(3,[1]),(4,[1,2,3])],
     [0]),
  (graphFromList [(0,[2]),(1,[3]),(2,[2,4]),(3,[0,2]),(4,[0,1,2,4])],
     [0,2,4,1,3]),
  (graphFromList [(0,[2]),(1,[2,4]),(2,[1]),(3,[0,1,2,4]),(4,[0,2])],
     [0,2,1,4]),
  (graphFromList [(0,[2]),(1,[2,4]),(2,[3]),(3,[1,2,3]),(4,[1])],
     [0,2,3,1,4]),
  (graphFromList [(0,[0]),(1,[0,2]),(2,[1]),(3,[1,2,3]),(4,[1,3,4])],
     [0]),
  (graphFromList [(0,[1,3]),(1,[3]),(2,[0,4]),(3,[0,2]),(4,[1,3,4])],
     [0,1,3,2,4]),
  (graphFromList [(0,[4]),(1,[0,4]),(2,[2,4]),(3,[0,1,3]),(4,[3])],
     [0,4,3,1]),
  (graphFromList [(0,[1,2,4]),(1,[1]),(2,[3]),(3,[1]),(4,[1,3,4])],
     [0,4,2,3,1]),
  (graphFromList [(0,[4]),(1,[0,1,3]),(2,[0,2]),(3,[2,4]),(4,[3])],
     [0,4,3,2]),
  (graphFromList [(0,[0,1,4]),(1,[1]),(2,[1,3,4]),(3,[0,2]),(4,[3])],
     [0,4,3,2,1]),
  (graphFromList [(0,[2]),(1,[0,2]),(2,[0,2]),(3,[2,4]),(4,[1,2,3])],
     [0,2]),
  (graphFromList [(0,[4]),(1,[0,4]),(2,[3]),(3,[0,1,3]),(4,[0,2])],
     [0,4,2,3,1]),
  (graphFromList [(0,[0]),(1,[1,3,4]),(2,[1,2,3]),(3,[3]),(4,[2,4])],
     [0]),
  (graphFromList [(0,[4]),(1,[1]),(2,[1,3,4]),(3,[1]),(4,[1,2,3])],
     [0,4,2,3,1]),
  (graphFromList [(0,[0,1,4]),(1,[0,4]),(2,[3]),(3,[3]),(4,[3])],
     [0,1,4,3]),
  (graphFromList [(0,[2,3,4]),(1,[3]),(2,[1,3,4]),(3,[3]),(4,[0,2])],
     [0,2,4,1,3]),
  (graphFromList [(0,[2]),(1,[1,3,4]),(2,[1]),(3,[3]),(4,[0,1,2,4])],
     [0,2,1,4,3]),
  (graphFromList [(0,[4]),(1,[0,1,3]),(2,[3]),(3,[1]),(4,[1,3,4])],
     [0,4,1,3]),
  (graphFromList [(0,[0]),(1,[3]),(2,[1]),(3,[0,2,3,4]),(4,[3])],
     [0]),
  (graphFromList [(0,[1,3]),(1,[3]),(2,[1,3,4]),(3,[0,4]),(4,[0,2])],
     [0,1,3,4,2]),
  (graphFromList [(0,[0]),(1,[0,4]),(2,[1]),(3,[0,2]),(4,[0,2])],
     [0]),
  (graphFromList [(0,[4]),(1,[1,2,3]),(2,[0,4]),(3,[3]),(4,[1,3,4])],
     [0,4,1,3,2]),
  (graphFromList [(0,[0,3,4]),(1,[0,4]),(2,[0,4]),(3,[2,4]),(4,[3])],
     [0,3,2,4]),
  (graphFromList [(0,[2]),(1,[1,2,3]),(2,[1]),(3,[3]),(4,[0,2])],
     [0,2,1,3]),
  (graphFromList [(0,[0,2,3]),(1,[3]),(2,[3]),(3,[3]),(4,[2,4])],
     [0,2,3]),
  (graphFromList [(0,[2]),(1,[1,3,4]),(2,[3]),(3,[0,1,2,4]),(4,[1])],
     [0,2,3,1,4]),
  (graphFromList [(0,[0,3,4]),(1,[2,4]),(2,[3]),(3,[0,2]),(4,[2,4])],
     [0,4,3,2]),
  (graphFromList [(0,[4]),(1,[3]),(2,[0,1,3]),(3,[0,1,2,4]),(4,[1])],
     [0,4,1,3,2]),
  (graphFromList [(0,[2]),(1,[0,4]),(2,[0,2]),(3,[1,2,3]),(4,[2,4])],
     [0,2]),
  (graphFromList [(0,[0]),(1,[1,3,4]),(2,[0,1,2,4]),(3,[3]),(4,[3])],
     [0]),
  (graphFromList [(0,[2]),(1,[1]),(2,[0,1,2,4]),(3,[2,4]),(4,[0,4])],
     [0,2,4,1]),
  (graphFromList [(0,[2]),(1,[0,4]),(2,[1,2,3]),(3,[3]),(4,[1,3,4])],
     [0,2,1,4,3]),
  (graphFromList [(0,[0,3,4]),(1,[0,2]),(2,[1]),(3,[3]),(4,[0,2])],
     [0,4,2,1,3]),
  (graphFromList [(0,[4]),(1,[0,1,3]),(2,[1]),(3,[0,2]),(4,[1,2,3])],
     [0,4,1,3,2]),
  (graphFromList [(0,[2]),(1,[3]),(2,[1,3,4]),(3,[0,4]),(4,[0,2])],
     [0,2,1,3,4]),
  (graphFromList [(0,[1,3]),(1,[3]),(2,[0,2,3,4]),(3,[0,4]),(4,[3])],
     [0,1,3,4]),
  (graphFromList [(0,[0,2,3]),(1,[0,2]),(2,[1]),(3,[0,4]),(4,[2,4])],
     [0,3,4,2,1]),
  (graphFromList [(0,[0]),(1,[0,4]),(2,[0,2]),(3,[1]),(4,[2,4])],
     [0]),
  (graphFromList [(0,[1,2,4]),(1,[3]),(2,[2,4]),(3,[0,4]),(4,[1])],
     [0,2,1,3,4]),
  (graphFromList [(0,[2]),(1,[0,1,2,4]),(2,[1,3,4]),(3,[3]),(4,[3])],
     [0,2,1,4,3]),
  (graphFromList [(0,[4]),(1,[1,3,4]),(2,[0,1,3]),(3,[3]),(4,[0,2])],
     [0,4,2,1,3]),
  (graphFromList [(0,[2]),(1,[0,1,2,4]),(2,[0,2]),(3,[1]),(4,[1])],
     [0,2]),
  (graphFromList [(0,[1,3]),(1,[0,2]),(2,[0,4]),(3,[2,4]),(4,[0,4])],
     [0,3,1,2,4]),
  (graphFromList [(0,[0,1,4]),(1,[0,4]),(2,[1]),(3,[1]),(4,[0,2])],
     [0,1,4,2]),
  (graphFromList [(0,[0]),(1,[1]),(2,[1,2,3]),(3,[1]),(4,[3])],
     [0]),
  (graphFromList [(0,[2,3,4]),(1,[1]),(2,[0,1,3]),(3,[3]),(4,[2,4])],
     [0,4,2,3,1]),
  (graphFromList [(0,[2]),(1,[3]),(2,[1,2,3]),(3,[1]),(4,[1,3,4])],
     [0,2,1,3]),
  (graphFromList [(0,[2]),(1,[2,4]),(2,[2,4]),(3,[1,3,4]),(4,[3])],
     [0,2,4,3,1]),
  (graphFromList [(0,[0]),(1,[1]),(2,[1,2,3]),(3,[1,2,3]),(4,[2,4])],
     [0]),
  (graphFromList [(0,[4]),(1,[0,1,3]),(2,[3]),(3,[1,3,4]),(4,[0,2])],
     [0,4,2,3,1]),
  (graphFromList [(0,[2]),(1,[3]),(2,[0,2]),(3,[0,2,3,4]),(4,[3])],
     [0,2]),
  (graphFromList [(0,[4]),(1,[3]),(2,[0,2,3,4]),(3,[2,4]),(4,[3])],
     [0,4,3,2]),
  (graphFromList [(0,[2]),(1,[0,1,3]),(2,[0,2,3,4]),(3,[3]),(4,[1])],
     [0,2,4,1,3]),
   -- sentinel
   (graphFromList [(0, [])], [0])
 ]

sccTestCases :: [(Graph Int, [[Int]])]
sccTestCases = [
  (graphFromList [(0,[1,3]),(1,[0,1,3]),(2,[3]),(3,[3]),(4,[0,4])],
     [[3],[0,1],[2],[4]]),
  (graphFromList [(0,[1,3]),(1,[0,4]),(2,[0,2]),(3,[1,3,4]),(4,[3])],
     [[0,1,3,4],[2]]),
  (graphFromList [(0,[1,3]),(1,[0,4]),(2,[1]),(3,[1,3,4]),(4,[2,4])],
     [[0,1,2,4,3]]),
  (graphFromList [(0,[1,3]),(1,[1]),(2,[0,1,2,4]),(3,[1]),(4,[2,4])],
     [[1],[3],[0],[2,4]]),
  (graphFromList [(0,[1,3]),(1,[0,2]),(2,[0,4]),(3,[1]),(4,[1,3,4])],
     [[0,1,3,4,2]]),
  (graphFromList [(0,[2]),(1,[2,4]),(2,[0,2]),(3,[2,4]),(4,[2,4])],
     [[0,2],[4],[1],[3]]),
  (graphFromList [(0,[2]),(1,[3]),(2,[3]),(3,[0,2,3,4]),(4,[0,2])],
     [[0,3,2,4],[1]]),
  (graphFromList [(0,[4]),(1,[1]),(2,[2,4]),(3,[3]),(4,[0,1,3])],
     [[1],[3],[0,4],[2]]),
  (graphFromList [(0,[4]),(1,[0,1,3]),(2,[3]),(3,[1,2,3]),(4,[1])],
     [[0,1,4,3,2]]),
  (graphFromList [(0,[4]),(1,[1,3,4]),(2,[1,3,4]),(3,[3]),(4,[0,2])],
     [[3],[0,4,1,2]]),
  (graphFromList [(0,[0]),(1,[0,4]),(2,[2,4]),(3,[0,2]),(4,[1,3,4])],
     [[0],[1,4,2,3]]),
  (graphFromList [(0,[2]),(1,[1]),(2,[3]),(3,[1,3,4]),(4,[1,2,3])],
     [[1],[2,4,3],[0]]),
  (graphFromList [(0,[1,3]),(1,[3]),(2,[3]),(3,[3]),(4,[0,2])],
     [[3],[1],[0],[2],[4]]),
  (graphFromList [(0,[0,2,3]),(1,[0,2]),(2,[1]),(3,[1,3,4]),(4,[1])],
     [[0,1,4,3,2]]),
  (graphFromList [(0,[0]),(1,[1]),(2,[1]),(3,[1,3,4]),(4,[0,1,3])],
     [[0],[1],[2],[3,4]]),
  (graphFromList [(0,[4]),(1,[0,4]),(2,[1,3,4]),(3,[2,4]),(4,[3])],
     [[0,1,2,3,4]]),
  (graphFromList [(0,[2]),(1,[3]),(2,[1,3,4]),(3,[3]),(4,[0,2])],
     [[3],[1],[0,4,2]]),
  (graphFromList [(0,[2,3,4]),(1,[0,2]),(2,[0,4]),(3,[3]),(4,[2,4])],
     [[3],[0,2,4],[1]]),
  (graphFromList [(0,[1,3]),(1,[1]),(2,[3]),(3,[0,2]),(4,[1,3,4])],
     [[1],[0,3,2],[4]]),
  (graphFromList [(0,[2]),(1,[0,2]),(2,[3]),(3,[1]),(4,[0,2])],
     [[0,1,3,2],[4]]),
  (graphFromList [(0,[0,2,3]),(1,[1,3,4]),(2,[3]),(3,[1]),(4,[3])],
     [[3,4,1],[2],[0]]),
  (graphFromList [(0,[0]),(1,[1,2,3]),(2,[1]),(3,[1,2,3]),(4,[0,2])],
     [[0],[1,2,3],[4]]),
  (graphFromList [(0,[2]),(1,[3]),(2,[0,4]),(3,[1,2,3]),(4,[1])],
     [[0,2,3,1,4]]),
  (graphFromList [(0,[0]),(1,[3]),(2,[1,2,3]),(3,[2,4]),(4,[0,4])],
     [[0],[4],[1,2,3]]),
  (graphFromList [(0,[0]),(1,[3]),(2,[3]),(3,[0,1,2,4]),(4,[2,4])],
     [[0],[1,3,2,4]]),
  (graphFromList [(0,[1,2,4]),(1,[0,1,3]),(2,[1]),(3,[1]),(4,[2,4])],
     [[0,1,3,2,4]]),
  (graphFromList [(0,[2,3,4]),(1,[0,2]),(2,[0,4]),(3,[2,4]),(4,[1])],
     [[0,1,4,2,3]]),
  (graphFromList [(0,[4]),(1,[1]),(2,[0,2]),(3,[0,4]),(4,[0,1,3])],
     [[1],[0,3,4],[2]]),
  (graphFromList [(0,[0,1,4]),(1,[3]),(2,[0,4]),(3,[1]),(4,[2,4])],
     [[1,3],[0,2,4]]),
  (graphFromList [(0,[0,3,4]),(1,[0,4]),(2,[1]),(3,[0,1,3]),(4,[1])],
     [[0,1,4,3],[2]]),
  (graphFromList [(0,[1,3]),(1,[1]),(2,[2,4]),(3,[0,2,3,4]),(4,[1])],
     [[1],[4],[2],[0,3]]),
  (graphFromList [(0,[2,3,4]),(1,[0,2]),(2,[3]),(3,[0,2]),(4,[0,4])],
     [[0,4,3,2],[1]]),
  (graphFromList [(0,[0,1,4]),(1,[3]),(2,[1]),(3,[0,2]),(4,[2,4])],
     [[0,3,1,2,4]]),
  (graphFromList [(0,[4]),(1,[0,4]),(2,[0,4]),(3,[0,2]),(4,[3])],
     [[0,2,3,4],[1]]),
  (graphFromList [(0,[0,2,3]),(1,[0,4]),(2,[1]),(3,[1]),(4,[0,1,3])],
     [[0,1,3,4,2]]),
  (graphFromList [(0,[2,3,4]),(1,[3]),(2,[1,3,4]),(3,[3]),(4,[0,2])],
     [[3],[1],[0,4,2]]),
  (graphFromList [(0,[4]),(1,[0,2]),(2,[0,2]),(3,[3]),(4,[0,2,3,4])],
     [[3],[0,2,4],[1]]),
  (graphFromList [(0,[0,2,3]),(1,[0,4]),(2,[1,2,3]),(3,[3]),(4,[1])],
     [[3],[0,1,4,2]]),
  (graphFromList [(0,[0]),(1,[0,2,3,4]),(2,[1,3,4]),(3,[1]),(4,[3])],
     [[0],[1,3,4,2]]),
  (graphFromList [(0,[0]),(1,[0,1,3]),(2,[0,2]),(3,[1]),(4,[0,2])],
     [[0],[1,3],[2],[4]]),
  (graphFromList [(0,[2]),(1,[1]),(2,[0,1,2,4]),(3,[2,4]),(4,[1])],
     [[1],[4],[0,2],[3]]),
  (graphFromList [(0,[4]),(1,[3]),(2,[3]),(3,[0,2]),(4,[1])],
     [[0,3,2,1,4]]),
  (graphFromList [(0,[0,3,4]),(1,[1,3,4]),(2,[1]),(3,[1]),(4,[1])],
     [[3,1,4],[0],[2]]),
  (graphFromList [(0,[1,3]),(1,[1,2,3]),(2,[2,4]),(3,[1]),(4,[3])],
     [[1,3,4,2],[0]]),
  (graphFromList [(0,[2]),(1,[0,1,3]),(2,[1]),(3,[0,2]),(4,[3])],
     [[0,1,2,3],[4]]),
  (graphFromList [(0,[0]),(1,[2,4]),(2,[1]),(3,[0,4]),(4,[0,1,2,4])],
     [[0],[1,2,4],[3]]),
  (graphFromList [(0,[0]),(1,[2,4]),(2,[1,2,3]),(3,[3]),(4,[1,2,3])],
     [[0],[3],[1,2,4]]),
  (graphFromList [(0,[2,3,4]),(1,[0,4]),(2,[0,4]),(3,[3]),(4,[3])],
     [[3],[4],[0,2],[1]]),
  (graphFromList [(0,[0]),(1,[3]),(2,[1]),(3,[1]),(4,[0,1,3])],
     [[0],[1,3],[2],[4]]),
  (graphFromList [(0,[2]),(1,[3]),(2,[1]),(3,[2,4]),(4,[0,2,3,4])],
     [[0,4,3,1,2]]),
  (graphFromList [(0,[4]),(1,[1]),(2,[1]),(3,[2,4]),(4,[0,2,3,4])],
     [[1],[2],[0,4,3]]),
  (graphFromList [(0,[0,3,4]),(1,[1]),(2,[0,2]),(3,[0,2]),(4,[3])],
     [[0,2,3,4],[1]]),
  (graphFromList [(0,[0,1,4]),(1,[0,4]),(2,[0,4]),(3,[3]),(4,[3])],
     [[3],[4],[0,1],[2]]),
  (graphFromList [(0,[1,3]),(1,[0,2]),(2,[0,4]),(3,[3]),(4,[1])],
     [[3],[0,1,4,2]]),
  (graphFromList [(0,[0]),(1,[1]),(2,[0,1,3]),(3,[3]),(4,[3])],
     [[0],[1],[3],[2],[4]]),
  (graphFromList [(0,[1,3]),(1,[0,4]),(2,[1]),(3,[0,1,2,4]),(4,[1])],
     [[0,1,4,2,3]]),
  (graphFromList [(0,[0,2,3]),(1,[3]),(2,[2,4]),(3,[3]),(4,[0,4])],
     [[3],[0,4,2],[1]]),
  (graphFromList [(0,[2]),(1,[0,1,2,4]),(2,[0,4]),(3,[0,2]),(4,[3])],
     [[0,2,3,4],[1]]),
  (graphFromList [(0,[4]),(1,[2,4]),(2,[1]),(3,[1,3,4]),(4,[0,1,3])],
     [[0,4,1,3,2]]),
  (graphFromList [(0,[4]),(1,[0,4]),(2,[1]),(3,[0,2,3,4]),(4,[1])],
     [[0,1,4],[2],[3]]),
  (graphFromList [(0,[1,3]),(1,[0,4]),(2,[3]),(3,[0,1,2,4]),(4,[3])],
     [[0,1,3,4,2]]),
  (graphFromList [(0,[2]),(1,[0,4]),(2,[0,4]),(3,[0,2]),(4,[1,2,3])],
     [[0,1,4,2,3]]),
  (graphFromList [(0,[1,2,4]),(1,[0,2]),(2,[0,4]),(3,[1]),(4,[3])],
     [[0,1,3,4,2]]),
  (graphFromList [(0,[2]),(1,[0,1,3]),(2,[2,4]),(3,[3]),(4,[1,3,4])],
     [[3],[0,1,4,2]]),
  (graphFromList [(0,[4]),(1,[3]),(2,[2,4]),(3,[0,2]),(4,[2,4])],
     [[4,2],[0],[3],[1]]),
  (graphFromList [(0,[0,1,2]),(1,[3]),(2,[0,4]),(3,[2,4]),(4,[3])],
     [[0,2,3,4,1]]),
  (graphFromList [(0,[1,2,4]),(1,[1]),(2,[3]),(3,[0,4]),(4,[0,4])],
     [[1],[0,4,3,2]]),
  (graphFromList [(0,[0]),(1,[3]),(2,[3]),(3,[2,4]),(4,[0,2,3,4])],
     [[0],[3,2,4],[1]]),
  (graphFromList [(0,[2]),(1,[1]),(2,[2,4]),(3,[0,2,3,4]),(4,[3])],
     [[0,3,4,2],[1]]),
  (graphFromList [(0,[4]),(1,[1]),(2,[1,2,3]),(3,[1,3,4]),(4,[3])],
     [[1],[4,3],[0],[2]]),
  (graphFromList [(0,[1,3]),(1,[1]),(2,[3]),(3,[0,4]),(4,[0,1,2,4])],
     [[1],[0,3,2,4]]),
  (graphFromList [(0,[2]),(1,[3]),(2,[0,1,2,4]),(3,[2,4]),(4,[2,4])],
     [[0,2,4,3,1]]),
  (graphFromList [(0,[1,3]),(1,[0,1,3]),(2,[2,4]),(3,[3]),(4,[0,4])],
     [[3],[0,1],[4],[2]]),
  (graphFromList [(0,[2]),(1,[0,2]),(2,[1,2,3]),(3,[2,4]),(4,[2,4])],
     [[0,1,2,4,3]]),
  (graphFromList [(0,[2]),(1,[1]),(2,[3]),(3,[0,4]),(4,[0,2])],
     [[0,3,2,4],[1]]),
  (graphFromList [(0,[2]),(1,[0,2]),(2,[1,2,3]),(3,[0,1,3]),(4,[3])],
     [[0,1,3,2],[4]]),
  (graphFromList [(0,[1,2,4]),(1,[1]),(2,[3]),(3,[0,1,3]),(4,[0,4])],
     [[1],[0,4,3,2]]),
  (graphFromList [(0,[2]),(1,[0,2]),(2,[0,1,3]),(3,[0,2]),(4,[0,4])],
     [[0,1,2,3],[4]]),
  (graphFromList [(0,[4]),(1,[1]),(2,[1,3,4]),(3,[0,1,3]),(4,[3])],
     [[1],[0,3,4],[2]]),
  (graphFromList [(0,[4]),(1,[0,2]),(2,[1,3,4]),(3,[0,2]),(4,[0,4])],
     [[0,4],[1,2,3]]),
  (graphFromList [(0,[0,1,2]),(1,[1,2,3]),(2,[3]),(3,[1]),(4,[2,4])],
     [[1,3,2],[0],[4]]),
  (graphFromList [(0,[4]),(1,[0,1,3]),(2,[1]),(3,[3]),(4,[0,2,3,4])],
     [[3],[0,1,2,4]]),
  (graphFromList [(0,[0,3,4]),(1,[2,4]),(2,[3]),(3,[3]),(4,[1])],
     [[3],[2],[4,1],[0]]),
  (graphFromList [(0,[1,2,4]),(1,[0,2,3,4]),(2,[1]),(3,[1]),(4,[3])],
     [[0,1,3,4,2]]),
  (graphFromList [(0,[0]),(1,[0,2]),(2,[1]),(3,[0,1,3]),(4,[1])],
     [[0],[1,2],[3],[4]]),
  (graphFromList [(0,[2]),(1,[1]),(2,[2,4]),(3,[2,4]),(4,[0,2])],
     [[0,4,2],[1],[3]]),
  (graphFromList [(0,[0]),(1,[0,4]),(2,[0,1,3]),(3,[3]),(4,[0,1,3])],
     [[0],[3],[1,4],[2]]),
  (graphFromList [(0,[1,3]),(1,[2,4]),(2,[3]),(3,[0,1,3]),(4,[3])],
     [[0,3,4,2,1]]),
  (graphFromList [(0,[4]),(1,[1,2,3]),(2,[0,1,3]),(3,[0,4]),(4,[1])],
     [[0,2,1,4,3]]),
  (graphFromList [(0,[2]),(1,[0,4]),(2,[1]),(3,[0,1,2,4]),(4,[0,4])],
     [[0,4,1,2],[3]]),
  (graphFromList [(0,[4]),(1,[0,4]),(2,[0,2]),(3,[0,1,3]),(4,[3])],
     [[0,1,3,4],[2]]),
  (graphFromList [(0,[0,1,4]),(1,[2,4]),(2,[0,2]),(3,[0,2]),(4,[1])],
     [[0,2,1,4],[3]]),
  (graphFromList [(0,[0,1,4]),(1,[1]),(2,[0,4]),(3,[1]),(4,[1])],
     [[1],[4],[0],[2],[3]]),
  (graphFromList [(0,[1,3]),(1,[3]),(2,[1]),(3,[2,4]),(4,[1])],
     [[1,4,2,3],[0]]),
  (graphFromList [(0,[1,3]),(1,[1]),(2,[3]),(3,[3]),(4,[3])],
     [[1],[3],[0],[2],[4]]),
  (graphFromList [(0,[1,3]),(1,[0,2]),(2,[3]),(3,[3]),(4,[3])],
     [[3],[2],[0,1],[4]]),
  (graphFromList [(0,[2]),(1,[1,3,4]),(2,[0,2]),(3,[3]),(4,[2,4])],
     [[0,2],[3],[4],[1]]),
  (graphFromList [(0,[2,3,4]),(1,[1,2,3]),(2,[1]),(3,[1]),(4,[1])],
     [[2,1,3],[4],[0]]),
  (graphFromList [(0,[1,2,4]),(1,[1,3,4]),(2,[1]),(3,[2,4]),(4,[1])],
     [[1,4,2,3],[0]]),
  (graphFromList [(0,[2]),(1,[0,4]),(2,[0,1,3]),(3,[0,1,3]),(4,[3])],
     [[0,1,3,4,2]]),
   -- sentinel
   (graphFromList [(0, [])], [[0]])
 ]

topoSortTestCases :: [(Graph Int, [Int])]
topoSortTestCases = [
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[1]),(4,[1])],
     [4,3,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[0,1,3]),(3,[1]),(4,[1])],
     [4,2,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[0,4]),(3,[2,4]),(4,[1])],
     [3,2,4,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[0,1,3]),(3,[1]),(4,[0,1,3])],
     [4,2,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[1]),(4,[0,2])],
     [4,3,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1,3,4]),(3,[0,4]),(4,[1])],
     [2,3,4,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[2,4]),(4,[1])],
     [3,4,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[1]),(4,[1,2,3])],
     [4,3,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[0,4]),(4,[1])],
     [3,4,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[1]),(4,[0,1,3])],
     [4,3,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[3]),(3,[1]),(4,[1,2,3])],
     [4,2,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[0,2]),(4,[1])],
     [4,3,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[0,4]),(3,[0,1,2,4]),(4,[1])],
     [3,2,4,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[0,4]),(4,[0,2])],
     [3,4,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[0,4]),(3,[1]),(4,[3])],
     [2,4,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[0,2]),(4,[1,2,3])],
     [4,3,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[0,2]),(4,[0,2])],
     [4,3,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[1]),(4,[3])],
     [4,3,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[3]),(3,[1]),(4,[0,1,3])],
     [4,2,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[0,4]),(3,[0,2]),(4,[1])],
     [3,2,4,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1,3,4]),(3,[1]),(4,[0,1,3])],
     [2,4,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[0,4]),(3,[1]),(4,[0,1,3])],
     [2,4,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[3]),(3,[1]),(4,[1])],
     [4,2,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[0,1,3]),(3,[0,4]),(4,[1])],
     [2,3,4,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1,3,4]),(3,[1]),(4,[1])],
     [2,4,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[0,1,3]),(3,[1]),(4,[1,2,3])],
     [4,2,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[0,4]),(3,[0,4]),(4,[1])],
     [3,2,4,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[3]),(3,[0,4]),(4,[1])],
     [2,3,4,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[0,1,2,4]),(4,[1])],
     [3,4,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[0,1,3]),(3,[1]),(4,[3])],
     [4,2,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[0,1,3]),(3,[1]),(4,[0,2])],
     [4,2,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[2,4]),(4,[0,2])],
     [3,4,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[0,4]),(3,[1]),(4,[1])],
     [3,2,4,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1,3,4]),(3,[1]),(4,[3])],
     [2,4,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[0,2]),(4,[0,1,3])],
     [4,3,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[3]),(3,[1]),(4,[3])],
     [4,2,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[3]),(3,[1]),(4,[0,2])],
     [4,2,3,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[0,1,2,4]),(4,[0,2])],
     [3,4,2,1,0]),
  (graphFromList [(0,[]),(1,[0]),(2,[1]),(3,[0,2]),(4,[3])],
     [4,3,2,1,0]),
   -- sentinel
   (graphFromList [(0, [])], [0])
 ]

testN :: Int -> TestResult
testN 1 = testMany "TestDeps.dependencySortLTestCases"
                   dependencySortLTestCases
                   (\ (_, expected) -> expected)
                   (\ (decls, _)    -> dependencySortL decls)

testN 2 = testMany "TestDeps.dependencySortKTestCases"
                   dependencySortKTestCases
                   (\ (_, expected) -> expected)
                   (\ (decls, _)    -> dependencySortK decls)

testN 3 = testMany "TestDeps.dfsTestCases" dfsTestCases
                   (\ (_, expected) -> expected)
                   (\ (graph, _)    -> dfs graph 0)

testN 4 = testMany "TestDeps.sccTestCases" sccTestCases
                   (\ (_, expected) -> expected)
                   (\ (graph, _)    -> stronglyConnectedComponents graph)

testN 5 = testMany "TestDeps.topoSortTestCases" topoSortTestCases
                   (\ (_, expected) -> expected)
                   (\ (graph, _)    -> topoSort graph)

test :: TestResult
test = mapM_ testN [1..5]
