module Part2 where

import Part2.Types

import Data.Function ((&))
import Control.Monad (msum)

------------------------------------------------------------
-- PROBLEM #6
--
-- Написать функцию, которая преобразует значение типа
-- ColorLetter в символ, равный первой букве значения
prob6 :: ColorLetter -> Char
prob6 RED = 'R'
prob6 GREEN = 'G'
prob6 BLUE = 'B'

------------------------------------------------------------
-- PROBLEM #7
--
-- Написать функцию, которая проверяет, что значения
-- находятся в диапазоне от 0 до 255 (границы входят)
prob7 :: ColorPart -> Bool
prob7 colorPart = getInt >= 0 && getInt <= 255
    where
        getInt = prob9 colorPart

------------------------------------------------------------
-- PROBLEM #8
--
-- Написать функцию, которая добавляет в соответствующее
-- поле значения Color значение из ColorPart
prob8 :: Color -> ColorPart -> Color
prob8 color part = case part of
    Red x -> color {red = red color + x}
    Green x -> color {green = green color + x}
    Blue x -> color {blue = blue color + x}

------------------------------------------------------------
-- PROBLEM #9
--
-- Написать функцию, которая возвращает значение из
-- ColorPart
prob9 :: ColorPart -> Int
prob9 colorPart = case colorPart of
    Red int   -> int
    Green int -> int
    Blue int  -> int

------------------------------------------------------------
-- PROBLEM #10
--
-- Написать функцию, которая возвращает компонент Color, у
-- которого наибольшее значение (если такой единственный)
prob10 :: Color -> Maybe ColorPart
prob10 color
  | red color > green color && red color > blue color = Just (Red (red color))
  | green color > blue color && green color > red color = Just (Green (green color))
  | blue color > green color && blue color > red color = Just (Blue (blue color))
  | otherwise = Nothing

------------------------------------------------------------
-- PROBLEM #11
--
-- Найти сумму элементов дерева
prob11 :: Num a => Tree a -> a
prob11 tree = sum (toList tree)

toList :: Tree a -> [a]
toList tree = maybeToList (left tree) ++ [root tree] ++ maybeToList (right tree)
  where
    maybeToList (Just x) = toList x
    maybeToList Nothing = []

------------------------------------------------------------
-- PROBLEM #12
--
-- Проверить, что дерево является деревом поиска
-- (в дереве поиска для каждого узла выполняется, что все
-- элементы левого поддерева узла меньше элемента в узле,
-- а все элементы правого поддерева -- не меньше элемента
-- в узле)
prob12 :: Ord a => Tree a -> Bool
prob12 tree = and
    [
        leftIsSearchTree,
        leftValueIsLess,
        rightValueIsMoreOrEqual,
        rightIsSearchTree
    ]
    where
        leftIsSearchTree  = maybe True prob12 $ tree & left
        rightIsSearchTree = maybe True prob12 $ tree & right

        leftValueIsLess = maybe True
            (\leftSubTree -> (leftSubTree & root) < (tree & root))
            $ tree & left

        rightValueIsMoreOrEqual = maybe True
            (\rightSubTree -> (rightSubTree & root) >= (tree & root))
            $ tree & right

------------------------------------------------------------
-- PROBLEM #13
--
-- На вход подаётся значение и дерево поиска. Вернуть то
-- поддерево, в корне которого находится значение, если оно
-- есть в дереве поиска; если его нет - вернуть Nothing
prob13 :: Ord a => a -> Tree a -> Maybe (Tree a)
prob13 value tree
    | value == (tree & root) = Just tree
    | otherwise = msum
        [
            do
                leftSubTree <- tree & left
                prob13 value leftSubTree,
            do
                rightSubTree <- tree & right
                prob13 value rightSubTree
        ]

------------------------------------------------------------
-- PROBLEM #14
--
-- Заменить () на числа в порядке обхода "правый, левый,
-- корень", начиная с 1
prob14 :: Tree () -> Tree Int
prob14 unitTree = traverseTree (getNodesCount unitTree) unitTree
    where
        traverseTree :: Int -> Tree () -> Tree Int
        traverseTree nodeNumber tree = Tree
            (do
                leftSubTree <- tree & left
                return $ traverseTree (pred nodeNumber) leftSubTree)
            nodeNumber
            (do
                rightSubTree <- tree & right
                return $ traverseTree (getRightDecrementFunc tree nodeNumber) rightSubTree)

        getRightDecrementFunc :: Tree a -> (Int -> Int)
        getRightDecrementFunc tree = case tree & left of
            Just leftSubTree -> subtract (getNodesCount leftSubTree + 1)
            Nothing -> pred

        getNodesCount :: Tree a -> Int
        getNodesCount tree = succ $ sum
            [
                maybe 0 getNodesCount (tree & left),
                maybe 0 getNodesCount (tree & right)
            ]

------------------------------------------------------------
-- PROBLEM #15
--
-- Выполнить вращение дерева влево относительно корня:
-- 4
--  \          6
--   6   =>   / \
--    \      4   8
--     8
prob15 :: Tree a -> Tree a
prob15 tree = maybe tree rotateLeft (right tree)
    where
        rotateLeft q = q { left = Just oldRoot }
           where
               oldRoot = tree { right = left q }

------------------------------------------------------------
-- PROBLEM #16
--
-- Выполнить вращение дерева вправо относительно корня:
--     8
--    /        6
--   6   =>   / \
--  /        4   8
-- 4
prob16 :: Tree a -> Tree a
prob16 tree = maybe tree rightRotation $ tree & left
    where
        rightRotation leftSubTree = leftSubTree { right = Just oldRoot }
            where
                oldRoot = tree { left = leftSubTree & right }

------------------------------------------------------------
-- PROBLEM #17
--
-- Сбалансировать дерево поиска так, чтобы для любого узла
-- разница высот поддеревьев не превосходила по модулю 1
-- (например, преобразовать в полное бинарное дерево)
prob17 :: Tree a -> Tree a
prob17 tree = case buildBalanced (toList tree) of
                   Just a -> a
                   Nothing -> tree

buildBalanced :: [a] -> Maybe (Tree a)
buildBalanced [] = Nothing
buildBalanced elts =
  Just (Tree
    (buildBalanced $ take half elts)
    (elts !! half)
    (buildBalanced $ drop (half + 1) elts))
  where
    half = length elts `quot` 2