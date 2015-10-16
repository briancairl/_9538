M           = meshread('queries/cat0_noise0.off');
G           = mesh2graph(M,2);


tic
d2          = zeros(1,size(G,2));
h           = [];

si          = 1:100:size(G,2);
for idx = si
    if isempty(h)
        h = binvalues(dijkstras(G,idx),0,500,1);
    else
        h = h + binvalues(dijkstras(G,idx),0,500,1);
    end
end
toc
h           = h/numel(si);

d1s         = sort(d1);
d2s         = sort(d2);
N           = 1:numel(d1);


plot(h,'r')
shg