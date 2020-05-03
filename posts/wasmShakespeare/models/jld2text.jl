using JLD;
using Flux;

function main()
  alfa=JLD.load("jld/alfa_model.jld"); folder="alfa/"
  beta1=JLD.load("jld/beta_model1.jld"); folder1="beta1/"
  beta2=JLD.load("jld/beta_model2.jld"); folder2="beta2/"
  beta3=JLD.load("jld/beta_model3.jld"); folder3="beta3/"

  writetofiles(alfa, folder, false)
  #writetofiles(beta1, folder1, true) #shakespeare model dont have Wp etc, only component stuff like Wm
  #writetofiles(beta2, folder2, true)
  #writetofiles(beta3, folder3, true)
  writetofiles(beta1, folder1, false) #so use these instead
  writetofiles(beta2, folder2, false)
  writetofiles(beta3, folder3, false)
end

#alfaW = alfa["W"][1]'[:]
function writetofile(a, filename)
  v = a'[:]; #important to transpose matrices cuz I wrote matmul in wasm that way
  open(filename, "w") do io
    N=length(v)
    for i=1:N-1
      write(io, string(Flux.data(v[i])),",")
    end
    write(io, string(Flux.data(v[N]))) #avoid last comma (not sure if needed)
  end
end

function writetofiles(a, n, beta)
  writetofile(a["W"][1], string(n,"W"))
  writetofile(a["bz"][1], string(n,"bz1"))
  writetofile(a["bz"][2], string(n,"bz2"))
  writetofile(a["b"][1], string(n,"b"))
  writetofile(a["Ur"][1], string(n,"Ur1"))
  writetofile(a["Ur"][2], string(n,"Ur2"))
  writetofile(a["bh"][1], string(n,"bh1"))
  writetofile(a["bh"][2], string(n,"bh2"))
  writetofile(a["bm"][1], string(n,"bm"))
  writetofile(a["Uh"][1], string(n,"Uh1"))
  writetofile(a["Uh"][2], string(n,"Uh2"))
  writetofile(a["Wh"][1], string(n,"Wh1"))
  writetofile(a["Wh"][2], string(n,"Wh2"))
  writetofile(a["br"][1], string(n,"br1"))
  writetofile(a["br"][2], string(n,"br2"))
  writetofile(a["Wr"][1], string(n,"Wr1"))
  writetofile(a["Wr"][2], string(n,"Wr2"))
  writetofile(a["Uz"][1], string(n,"Uz1"))
  writetofile(a["Uz"][2], string(n,"Uz2"))
  writetofile(a["Wz"][1], string(n,"Wz1"))
  writetofile(a["Wz"][2], string(n,"Wz2"))
  writetofile(a["Wm"][1], string(n,"Wm"))
  if (beta)
    #for beta models only:
    writetofile(a["Wp"][1], string(n,"Wp1"))
    writetofile(a["Wp"][2], string(n,"Wp2"))
    writetofile(a["Wp"][3], string(n,"Wp3"))
    writetofile(a["bp"][1], string(n,"bp1"))
    writetofile(a["bp"][2], string(n,"bp2"))
    writetofile(a["bp"][3], string(n,"bp3"))
  end
end

main()
