with open('C:/Users/lsy20/Downloads/levels.txt','r') as f1:
    with open('C:/Users/lsy20/Downloads/levels2.txt','w') as f2:
        for i in range(115):
            line=f1.readline()
            line='"'+line[0:-5]+'",'
            f2.writelines(line+"\n")
            print(line)

