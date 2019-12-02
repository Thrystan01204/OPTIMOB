f = open("plateformes.csv", "r")
out = open("code.txt", "w")

i = 0
for line in f:
    if(i > 0):
        data = line.split(";")
        out.write("plateformes.add(new Plateforme({},{},{},false)); //P{}\n".format(data[0], data[1], data[2], i))
        if(data[3] != ""):
            out.write("Mercenaire m{} = new Mercenaire({},{},{},{});\n".format(i, data[0], data[1], data[2], data[3]))
            out.write("m{}.level = {};\n".format(i, data[4]))
            out.write("ennemis.add(m{});\n".format(i))
    i+=1

out.close()
f.close()