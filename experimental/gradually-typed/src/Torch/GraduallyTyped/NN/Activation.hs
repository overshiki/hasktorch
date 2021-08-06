{-# LANGUAGE DataKinds #-}
{-# LANGUAGE DeriveGeneric #-}
{-# LANGUAGE DerivingStrategies #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE KindSignatures #-}
{-# LANGUAGE MultiParamTypeClasses #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TupleSections #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE UndecidableInstances #-}
{-# OPTIONS_GHC -Wall #-}

module Torch.GraduallyTyped.NN.Activation where

import GHC.Generics (Generic)
import GHC.TypeLits (Nat, Symbol)
import Torch.GraduallyTyped.NN.Class (HasForward (..), HasInitialize (..), HasStateDict (..), ModelSpec)
import Torch.GraduallyTyped.NN.Functional.Activation (gelu, geluNew, relu)
import Torch.GraduallyTyped.NN.Functional.NonLinearActivation (SoftmaxF, softmax)
import Torch.GraduallyTyped.Shape (By, SSelectDim, SelectDim)
import Torch.GraduallyTyped.Tensor.MathOperations.Pointwise (tanh)
import Torch.GraduallyTyped.Tensor.Type (Tensor)
import Prelude hiding (tanh)

data Softmax (selectDim :: SelectDim (By Symbol Nat)) where
  Softmax ::
    forall selectDim.
    {softmaxSelectDim :: SSelectDim selectDim} ->
    Softmax selectDim
  deriving stock (Generic)

type instance ModelSpec (Softmax selectDim) = Softmax selectDim

instance
  HasInitialize
    (Softmax selectDim)
    generatorDevice
    (Softmax selectDim)
    generatorDevice
  where
  initialize spec = pure . (spec,)

instance HasStateDict (Softmax selectDim) where
  fromStateDict spec _ = pure spec
  toStateDict _ _ = pure ()

instance
  (output ~ Tensor requiresGradient layout device dataType (SoftmaxF selectDim shape)) =>
  HasForward
    (Softmax selectDim)
    (Tensor requiresGradient layout device dataType shape)
    generator
    output
    generator
  where
  forward Softmax {..} input = pure . (softmax softmaxSelectDim input,)

data Relu where
  Relu :: Relu
  deriving stock (Eq, Ord, Show, Generic)

type instance ModelSpec Relu = Relu

instance
  HasInitialize
    Relu
    generatorDevice
    Relu
    generatorDevice
  where
  initialize spec = pure . (spec,)

instance HasStateDict Relu where
  fromStateDict spec _ = pure spec
  toStateDict _ _ = pure ()

instance
  HasForward
    Relu
    (Tensor requiresGradient layout device dataType shape)
    generator
    (Tensor requiresGradient layout device dataType shape)
    generator
  where
  forward Relu input = pure . (relu input,)

data Gelu where
  Gelu :: Gelu
  deriving stock (Eq, Ord, Show, Generic)

type instance ModelSpec Gelu = Gelu

instance
  HasInitialize
    Gelu
    generatorDevice
    Gelu
    generatorDevice
  where
  initialize spec = pure . (spec,)

instance HasStateDict Gelu where
  fromStateDict spec _ = pure spec
  toStateDict _ _ = pure ()

instance
  HasForward
    Gelu
    (Tensor requiresGradient layout device dataType shape)
    generator
    (Tensor requiresGradient layout device dataType shape)
    generator
  where
  forward Gelu input = pure . (gelu input,)

data GeluNew where
  GeluNew :: GeluNew
  deriving stock (Eq, Ord, Show, Generic)

type instance ModelSpec GeluNew = GeluNew

instance
  HasInitialize
    GeluNew
    generator
    GeluNew
    generator
  where
  initialize spec = pure . (spec,)

instance HasStateDict GeluNew where
  fromStateDict spec _ = pure spec
  toStateDict _ _ = pure ()

instance
  HasForward
    GeluNew
    (Tensor requiresGradient layout device dataType shape)
    generator
    (Tensor requiresGradient layout device dataType shape)
    generator
  where
  forward GeluNew input = pure . (geluNew input,)

data Tanh where
  Tanh :: Tanh
  deriving stock (Eq, Ord, Show, Generic)

type instance ModelSpec Tanh = Tanh

instance
  HasInitialize
    Tanh
    generator
    Tanh
    generator
  where
  initialize spec = pure . (spec,)

instance HasStateDict Tanh where
  fromStateDict spec _ = pure spec
  toStateDict _ _ = pure ()

instance
  HasForward
    Tanh
    (Tensor requiresGradient layout device dataType shape)
    generator
    (Tensor requiresGradient layout device dataType shape)
    generator
  where
  forward Tanh input = pure . (tanh input,)
