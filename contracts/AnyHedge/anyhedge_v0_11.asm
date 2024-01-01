; Compiled on 2022-05-11
; Opcode count: 109 of 201
; Bytesize: 337~353 (158 + 179~195) of 520

<maturityTimestamp> <startTimestamp>                      ; 2 * 4 + 2 * 1 bytes     |   10 bytes
<highLiquidationPrice> <lowLiquidationPrice>              ; 2 * (2~4) + 2 * 1 bytes | 6-10 bytes
<payoutSats> <nominalUnitsXSatsPerBch>                    ; 2 * (2~8) + 2 * 1 bytes | 6-18 bytes
<oraclePublicKey>                                         ; 33 + 1 byte             |   34 bytes
<longLockScript> <hedgeLockScript>                        ; 2 * ~26 + 2 * 1 bytes   |   54 bytes
<enableMutualRedemption>                                  ; 1 byte                  |    1 byte
<longMutualRedeemPublicKey> <hedgeMutualRedeemPublicKey>  ; 2 * 33 + 2 * 1 bytes    |   68 bytes

; Mutual Redeem
OP_12 OP_PICK OP_0 OP_NUMEQUAL OP_IF
	; Check that mutual redemption is enabled
	OP_ROT OP_VERIFY
	; Verify hedge sig
	OP_12 OP_ROLL OP_SWAP OP_CHECKSIGVERIFY
	; Verify long sig
	OP_11 OP_ROLL OP_SWAP OP_CHECKSIGVERIFY
	; Cleanup
	OP_2DROP OP_2DROP OP_2DROP OP_2DROP OP_2DROP OP_1
; Payout
OP_ELSE OP_12 OP_ROLL OP_1 OP_NUMEQUALVERIFY
	; Check for exactly 1 input
	OP_TXINPUTCOUNT OP_1 OP_NUMEQUALVERIFY
	; Verify previous message signature
	OP_15 OP_ROLL OP_15 OP_PICK OP_7 OP_PICK OP_CHECKDATASIGVERIFY
	; Verify settlement message signature
	OP_13 OP_ROLL OP_13 OP_PICK OP_7 OP_ROLL OP_CHECKDATASIGVERIFY
	; Extract previous oracle mesages data sequence
	OP_12 OP_PICK OP_8 OP_SPLIT OP_NIP OP_4 OP_SPLIT OP_DROP OP_BIN2NUM
	; Verify that oracle message is price data (not metadata)
	OP_DUP OP_0 OP_GREATERTHAN OP_VERIFY
	; Extract the current oracle mesages data sequence
	OP_12 OP_PICK OP_8 OP_SPLIT OP_NIP OP_4 OP_SPLIT OP_DROP OP_BIN2NUM
	; Verify that the oracle messages are directly following eachother
	OP_1SUB OP_NUMEQUALVERIFY
	; Extract the previous messages timestamp
	OP_12 OP_ROLL OP_4 OP_SPLIT OP_DROP OP_BIN2NUM
	; Verify the the previous message is before maturity.
	OP_11 OP_PICK OP_LESSTHAN OP_VERIFY
	; Extract the settlement message's price.
	OP_11 OP_PICK OP_12 OP_SPLIT OP_NIP OP_BIN2NUM
	; Fail if the oracle price is out of specification.
	OP_DUP OP_0 OP_GREATERTHAN OP_VERIFY
	; Clamp the price within the allowed price range
	OP_9 OP_PICK OP_MIN OP_8 OP_PICK OP_MAX
	; Extract the settlement message's timestamp.
	OP_12 OP_ROLL OP_4 OP_SPLIT OP_DROP OP_BIN2NUM
	; Fail if the oracle timestamp is before the earliest liquidation time
	OP_DUP OP_12 OP_ROLL OP_GREATERTHANOREQUAL OP_VERIFY
	; onOrAfterMaturity
	OP_11 OP_ROLL OP_GREATERTHANOREQUAL
	; priceOutOfBounds
	OP_OVER OP_10 OP_ROLL OP_1ADD OP_11 OP_ROLL OP_WITHIN OP_NOT
	; require(onOrAfterMaturity || priceOutOfBounds);
	OP_BOOLOR OP_VERIFY
	; NOTE: 2202 = 546 dust
	2202
	; hedgeSats
	OP_DUP OP_8 OP_ROLL OP_3 OP_ROLL OP_DIV OP_MAX
	; longSats
	OP_SWAP OP_7 OP_ROLL OP_2 OP_PICK OP_SUB OP_MAX
	; Verify that there's only 2 outputs
	OP_TXOUTPUTCOUNT OP_2 OP_NUMEQUALVERIFY
	; verify hedge sats are correct
	OP_0 OP_OUTPUTVALUE OP_ROT OP_NUMEQUALVERIFY
	; verify hedge lockscript is correct
	OP_0 OP_OUTPUTBYTECODE OP_5 OP_ROLL OP_EQUALVERIFY
	; verify long sats is correct
	OP_1 OP_OUTPUTVALUE OP_NUMEQUALVERIFY
	; verify long lockscript is correct
	OP_1 OP_OUTPUTBYTECODE OP_4 OP_ROLL OP_EQUAL
	; Cleanup
	OP_NIP OP_NIP OP_NIP
OP_ENDIF
