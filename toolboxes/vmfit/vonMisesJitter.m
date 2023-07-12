function Data = vonMisesJitter(X, Ang, varargin)

% wrapper function to jitter data to get von mises fit to work.
% gamma flag for vonMisesFitGamma or regs. Jitter size defaults to 20% mean
% of X. leaving ang jitter at ~1 deg

p = inputParser();

% p.addParameter('jittersize',[]);
p.addParameter('baselinecomparison',false,@(x) validateattributes(x,{'logical'},{'nonempty'}));
p.addParameter('gamma',false,@(x) validateattributes(x,{'logical'},{'nonempty'}));
p.addParameter('phatalt_start',[0 0 0 0],@(x) validateattributes(x,{'numeric'}));
p.addParameter('phatnull_start',[0],@(x) validateattributes(x,{'numeric'}));

p.parse(varargin{:});

args = p.Results;

% if isempty(args.jittersize)
    jittersize = 0.2*mean(X);
% end

check = 1;
ind = 1;

while check && ind < 1e2
    nSamples = length(X);
    Datatmp = vonMisesFit(X+jittersize*rand(1,nSamples),Ang+0.02*rand(1,nSamples),'baselinecomparison',args.baselinecomparison,'gamma',args.gamma);
    ind = ind + 1;
    if ~isnan(Datatmp.pci_alt), check = 0; end
end
if ~isnan(Datatmp.pci_alt)
    Data = vonMisesFit(X,Ang,'phatalt_start',Datatmp.phat_alt,'baselinecomparison',args.baselinecomparison,'gamma',args.gamma);
else
    disp('jitter didnt work!')
    Data = Datatmp;
end

end