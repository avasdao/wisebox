# Wise Delegate Template

This template allows for dynamic contract execution, as seen in Polymorph and Ethereum `delegate_call` upgradeable contracts.

> NOTE: We're using the Nexa-exclusive OP_EXEC command.

```
# A namespace is required to ID each individual (delegated) Script template.
<NAMESPACE> (e.g. POLYPOW01|09504F4C59504F573031)
OP_DROP

// NOTE: Script authors may add as many additional `<UNIQUE_ID><OP_DROP>`s
//       here as needed (e.g. for on-chain indexing).

# The following stack `PUSH`es are provided by the Script satisfier.
# NOTE: The following data is *NOT* visible and therefore *DOES NOT* affect
#       the (ID) hash of the Script template.
[ PUSH template placeholder ] `0`
[ PUSH optional param #1 ]    `0000000000000000000000000000000000000000`
[ PUSH optional param #2 ]    `0000000000000000000000000000000000000000`
[ PUSH optional param #3 ]    `0000000000000000000000000000000000000000`
[ PUSH # params ]             `0,51-60`
[ PUSH # returns ]            `0,51-60`
[ PUSH Script template ]      `0123456789ABCDEF`

# The Script template is copied to the <placeholder> and then
# verified for authenticity by its *active* authorization.
OP_1NEGATE
OP_PLACE
OP_HASH160
OP_FROMALTSTACK (*final* constraint) [ *authorized* Script template hash ]
OP_EQUALVERIFY
OP_EXEC       👈 this is where all the *MAGIC* happens ✨
```
