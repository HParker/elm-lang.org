module Form where

import open Graphics.Input
import open Http

-- Helpers
isEmptyString : String -> Bool
isEmptyString x = x == ""

getErrors : String -> String -> String -> String -> [String]
getErrors first last email remail =
  justs <| map (\(err,msg) -> if err then Just msg else Nothing)
  [ (isEmptyString first  , "First name required.")
  , (isEmptyString last   , "Last name required.")
  , (isEmptyString email  , "Must enter your email address.")
  , (isEmptyString remail , "Must re-enter your email address.")
  , (email /= remail, "Email addresses do not match.")
  ]

url : String -> String -> String -> String
url first last email = 
    "http://elm-lang.org/login?first=" ++ first ++ "&last=" ++ last ++ "&email="++ email

-- Signals
(firstBox , first)  = field "First Name"
(lastBox  , last)   = field "Last Name"
(emailBox , email)  = field "Your Email"
(remailBox, remail) = field "Re-enter Email"
(butn     , press)  = button "Submit"

errors : Signal [String]
errors = lift4 getErrors first last email remail

sendable : Signal Bool
sendable = sampleOn press <| lift isEmpty errors

-- Display
fieldWith : String -> Element -> Element
fieldWith txt fld =
  flow right
    [ container 120 32 midRight <| plainText txt
    , container 200 32 middle <| size 180 26 fld ]

showErrors : [String] -> Element
showErrors errs =
  if isEmpty errs then spacer 10 10 else
    flow down <| map (text . Text.color red . toText) errs

entry : Element -> Element -> Element -> Element -> [String] -> Element
entry f l em r e = (color (rgb 230 230 230) . flow down) <|
               [ fieldWith "First Name:" f
               , fieldWith "Last Name:"  l
               , fieldWith "Your Email:" em
               , fieldWith "Re-enter Email:" r
               , showErrors e
               , container 310 40 midRight <| size 60 30 butn
               ]

-- HTTP control
sendRequest : Signal String
sendRequest = keepWhen sendable "" <| lift3 url first last email

getLogin : Signal String -> Signal (Response String)
getLogin req = send <| lift (\r -> post r "") req

-- HTTP printing  
prettyPrint : Response String -> Element
prettyPrint res = case res of
  Waiting -> plainText ""
  Failure _ _ -> plainText ""
  Success a -> plainText a

main : Signal Element
main = 
  above
    <~ (lift (container 360 360 topLeft) <| entry <~ firstBox ~ lastBox ~ emailBox ~ remailBox ~ errors)
     ~ (lift prettyPrint <| getLogin sendRequest)

