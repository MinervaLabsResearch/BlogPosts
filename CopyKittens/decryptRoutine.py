import base64
with open("obfuscatedStrings.txt","r") as f:
    lines = f.readlines()

for encryptedString in lines:
    i = len(encryptedString)-1
    tempString =""
    while i >= 0:
        char = str(encryptedString[i])
        if char == "Z":
            char = "A"
        elif char == "1":
            char = "="
        elif char == "c":
            char = "R"
        elif char == "d":
            char = "V"
        elif char == "e":
            char = "c"
        elif char == "0":
            char = "d"
        elif char == "R":
            char = "e"
        elif char == "V":
            char = "0"
        elif char == "=":
            char = "1"
        elif char == "A":
            char = "Z"
        tempString += char
        i-=1
    if "\n" in tempString:
        print encryptedString[0:-1] + " : " + base64.b64decode(tempString[1:])
    else:
        print encryptedString[0:-1] + " : " + base64.b64decode(tempString)


