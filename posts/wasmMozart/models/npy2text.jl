using JLD;
using Flux;
using NPZ

function MozartWolfgangAmadeus(datafolder)
path="npy/MozartWolfgangAmadeus/"
songs=["mz_311_1_format0.npy",
"mz_311_2_format0.npy",
"mz_311_3_format0.npy",
"mz_330_1_format0.npy",
"mz_330_2_format0.npy",
"mz_330_3_format0.npy",
"mz_331_1_format0.npy",
"mz_331_2_format0.npy",
"mz_331_3_format0.npy",
"mz_332_1_format0.npy",
"mz_332_2_format0.npy",
"mz_332_3_format0.npy",
"mz_333_1_format0.npy",
"mz_333_2_format0.npy",
"mz_333_3_format0.npy",
"mz_545_1_format0.npy",
"mz_545_2_format0.npy",
"mz_545_3_format0.npy",
"mz_570_1_format0.npy",
"mz_570_2_format0.npy",
"mz_570_3_format0.npy"]
data=[NPZ.npzread(string(datafolder,path,song)) for song in songs]
return data
end

function main()
  alfa=JLD.load("alfa_model.jld"); folder="alfa/"
  beta1=JLD.load("beta_model1.jld"); folder1="beta1/"
  beta2=JLD.load("beta_model2.jld"); folder2="beta2/"
  beta3=JLD.load("beta_model3.jld"); folder3="beta3/"

  writetofiles(alfa, folder)
  writetofiles(beta1, folder1, true)
  writetofiles(beta2, folder2, true)
  writetofiles(beta3, folder3, true)
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
