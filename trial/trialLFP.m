function [Lfp] = trialLFP(o,varargin)

%  loads lfp data for a trial, onseted to particular trial
%  timepoints
%
% Input:
%   o = mdbase object with LFP data
%
% Optional arguments:
%   channels - channels to load LFP data for (defaut: o.lfp.numChannels)
%   onset - time point to onset data to (ie target onset, stimulus onset, etc) default is trial start
%   onsetvector? - maybe a way of inputing an optional alingment time points, like
%   saccade times, onseted to start of trial
%   trind = logical vector to tell which trials to use
%   bn - time bin around onset time
%
% Output
%   Lfp - the local field potential signal(s) (mV?) in ms [TRIAL,NCH,TIME] or [TRIAL,TIME]
%
% 2023-01-03 - Maureen Hagan <maureen.hagan@monash.edu>

% not sure the best way to deal with onsetments. in ns, stimuli and
% behaviours are a bit different. also, saccade times are something
% processed separaetly. to start, this will onset to onset of a simtulus
% and we'll go from there. if no onset given, will onset to firstFrame of
% the trial. 

% also = successful trials arent defined in the marmlab object. so optional
% vector input to account for this.


p = inputParser();
p.KeepUnmatched = true;
p.addParameter('channels',[],@(x) validateattributes(x,{'numeric'},{'positive','>=',min(o.lfp.numChannels),'<=',max(o.lfp.numChannels)}));
p.addParameter('onset','',@(x) ischar(x) || isempty(x));
p.addParameter('bn',[0,1000]); %, @(x) validateattributes(x,{'numeric'},{'positive','==',2))
p.addParameter('onsetvector',[],@(x) validateattributes(x,{'numeric'},{'positive','>=',min(o.lfp.numTrials),'<=',max(o.lfp.numTrials)}));
p.addParameter('trind',[]); %, @(x) validateattributes(x,{'logical'}))

p.parse(varargin{:});

args = p.Results;

if isempty(args.channels), channels = 1:o.lfp.numChannels; end

lfp = o.lfp.raw'; % trials x samples > will need resizing for more than one channel

%find which trials to use
if isempty(args.trind)
    if isprop(o,'complete'), trind = o.complete;
    else, trind = true(1,o.lfp.numTrials);
    end
else, trind = args.trind;
end

% get an onset time in ms for each trial
if isempty(args.onsetvector)
    if ~isempty(args.onset)
    	onsets = (o.meta.(args.onset).startTime.time - o.meta.cic.firstFrame.time).*1e3; % onset time to the nearest ms
    else
        onsets = ones(1,o.lfp.numTrials);
    end
else, onsets = args.onsetvector;
end

start = onsets + args.bn(1); stop = onsets + args.bn(2);

if max(stop(trind)) > o.lfp.numSamples ||  min(start(trind)) < 1
    error('your window is bigger than your trial!') 
end

Lfp = nan(sum(trind), o.lfp.numChannels, diff(args.bn)+1);

for ich = channels
Lfp(:,ich,:) = lfp(trind,start:stop); % will need indexing for more than one channel!
    
end

Lfp = squeeze(Lfp);

end

