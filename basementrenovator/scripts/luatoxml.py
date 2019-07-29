import re

def replace(s, search, replace):
    # Locate the substring to replace
    return s.replace(search, replace)

def replaceRegex(s, search, repl):
    return re.sub(search, repl, s)

def run(filename):

    if not filename.endswith(".lua"):
        print("Either file was not obtained or was not a valid Lua file.")
        return 1

    fContent = open(filename).read()

    try:
        fContent = replaceRegex(fContent, "return {\\s*([^(^\\s*{)]*,)?", r"<rooms \1>\n")
        fContent = replaceRegex(fContent, "{ISDOOR=true, (.*)},", r"<door \1 />")
        fContent = replaceRegex(fContent, "(SLOT=\\d+(, )?)", "")
        fContent = replaceRegex(fContent, "{([^(ISDOOR)].*)},", r"<entity \1 />")
        fContent = replaceRegex(fContent, "{(TYPE.*,)", r"<room \1>")
        fContent = replaceRegex(fContent, "{ISDOOR=false, ([^\\n]*),", r"<spawn \1>")
        fContent = replaceRegex(fContent, "},(\\s*)},", r"</spawn>\1</room>")
        fContent = replace(fContent, "},", "</spawn>")
        fContent = replace(fContent, "}", "</rooms>")

        fContent = replace(fContent, "TYPE", "type")
        fContent = replace(fContent, "VARIANT", "variant")
        fContent = replace(fContent, "SUB", "sub")
        fContent = replace(fContent, "NAME", "name")
        fContent = replace(fContent, "DIFFICULTY", "difficulty")
        fContent = replace(fContent, "WEIGHT", "weight")
        fContent = replace(fContent, "WIDTH", "width")
        fContent = replace(fContent, "HEIGHT", "height")
        fContent = replace(fContent, "SHAPE", "shape")
        fContent = replace(fContent, "METADATA=nil", "")
        fContent = replace(fContent, "METADATA", "metadata")
        fContent = replace(fContent, " GRIDX=", " x=")
        fContent = replace(fContent, " GRIDY=", " y=")
        fContent = replace(fContent, "EXISTS", "exists")
        fContent = replace(fContent, ",", "")
        fContent = replace(fContent, "true", "\"True\"")
        fContent = replace(fContent, "false", "\"False\"")
        fContent = replaceRegex(fContent, "=(\\-?\\d+(\\.\\d+)?)", r'="\1"') # replace numbers with quoted versions
    except Exception as e:
        print('ERROR CONVERTING:', e)
        return 2

    filename = replace(filename, ".lua", ".xml")
    with open(filename, 'w') as outXml:
        outXml.write(fContent)

    print('Success!')
    return 0


if __name__ == '__main__':
    import sys
    run(sys.argv[1])