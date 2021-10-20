using Parsers

struct TwoPortData
  fs::Array{Real,1}
  S11::Array{Complex,1}
  S12::Array{Complex,1}
  S21::Array{Complex,1}
  S22::Array{Complex,1}
end

struct OnePortData
  fs::Array{Real,1}
  S11::Array{Complex,1}
end

function read_one_port(fpath)
  open(fpath) do file
    for _ in 1:6
      readline(file)
    end
    freqs = read_next_unit(file, dtype=Float64)
    S = read_next_unit(file, dtype=ComplexF64)
    OnePortData(freqs,S)
  end
end

function read_two_port(fpath)
  open(fpath) do file
    for _ in 1:9
      readline(file)
    end
    freqs = read_next_unit(file, dtype=Float64)
    S11 = read_next_unit(file, dtype=ComplexF64)
    S12 = read_next_unit(file, dtype=ComplexF64)
    S21 = read_next_unit(file, dtype=ComplexF64)
    S22 = read_next_unit(file, dtype=ComplexF64)
    TwoPortData(freqs,S11,S12,S21,S22)
  end
end

function read_next_unit(io; dtype=Float64, target=nothing)
  if target==nothing
    target = convert(Array{dtype,1},[])
  end
  l = readline(io)
  if l[end-4:end] != "BEGIN"
    error("attempted to start reading block, but first line was invalid: $(l)")
  end
  while true
    l = readline(io)
    if l[end-2:end] == "END"
      break
    end
    append!(target, parse_for_ads(dtype,l))
  end
  return target
end

function parse_for_ads(dtype,s)
  if dtype==ComplexF64
    sclean = replace(filter(c->!isspace(c),s),','=>'+')*"i"
    return parse(ComplexF64, sclean)
  else
    return parse(dtype,s)
  end
end
