//
//  SuiBCSBridged.swift
//  LeanSui
//
//  A leansui-local marker protocol that refines LeanSuiBCS.KeyProtocol.
//
//  swift-java emits a Java `implements <P>` for every protocol a bridged type
//  conforms to DIRECTLY, using the protocol's *simple* name. For a protocol from
//  another module (KeyProtocol lives in LeanSuiBCS → package
//  `com.variance.nearby.leansui.bcs`) that simple name is unqualified and fails
//  to compile in the `com.variance.nearby.leansui` package.
//
//  However, swift-java DROPS inherited protocols from a *protocol's* own `extends`
//  clause (observed: the generated `PublicKeyProtocol` interface does not extend
//  `KeyProtocol`). So a bridged type that conforms to THIS marker emits
//  `implements SuiBCSBridged` (same package → resolves), and the generated
//  `SuiBCSBridged` interface drops the cross-module `KeyProtocol`. The Swift-side
//  BCS machinery is unaffected because `SuiBCSBridged: KeyProtocol`.
//
import LeanSuiBCS

public protocol SuiBCSBridged: KeyProtocol {}
