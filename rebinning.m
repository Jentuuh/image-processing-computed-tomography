fan_beam_proj = imread("./data/Divergent_Projection/lotus_divergent.png");
fan_beam_proj = double(fan_beam_proj/255);
transpose(fan_beam_proj)

d = 540;
reconstruction = ifanbeam(fan_beam_proj,d);

reconstruction
