import re

# set this vars to point to the desired files
input_file = "encrypted_script.au3"
output_file = "decrypted_script.au3"

key = 118831864


def dec_func(raw_str_in):

    """
    :param raw_str_in: a string to decrypt, passed as a regex match object
    :return: decrypted string
    """

    try:
        # parsing the string to decrypt
        start = raw_str_in.regs[0][0]
        end = raw_str_in.regs[0][1]
        str_in = raw_str_in.string[start:end].replace("j4fi5um0su4n(\"", "").replace("\", $k3bh7fu4xx2k)", "")

        # implementing the decryption routine in python
        n = 2
        splitted_line = [str_in[i:i+n] for i in range(0, len(str_in), n)]
        splitted_line_int = []
        for obj in splitted_line:
            splitted_line_int.append(int(obj,16))
        str_in = ''.join(map(chr, splitted_line_int))
        buff1 = ""
        buff2 = ""

        for letter in str_in:
            buff3 = letter
            if letter.isdigit():
                buff2 += buff3
            else:
                buff1 += chr(int(buff2) - key)
                buff2 = ""

        return "\"{0}\"".format(buff1)
    except:
        return "undecryptable string"


if __name__ == '__main__':
    # open file to decrypt
    with open(input_file, 'r') as f:
        content = f.read()

    # decrypt, any match is sent to the decryption function
    dec_func_re = re.compile(r"j4fi5um0su4n\(([^,]*),\s+\$k3bh7fu4xx2k\)")
    content_new = re.sub(dec_func_re, dec_func, content)

    # remove redundant string concatenations
    content_new = content_new.replace("\" & \"", "")

    # write the output to a new file
    with open(output_file, 'w+') as f:
        f.write(content_new)
