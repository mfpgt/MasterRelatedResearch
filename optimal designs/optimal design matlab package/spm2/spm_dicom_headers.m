function hdr = spm_dicom_headers(P)
% Read header information from DICOM files
% FORMAT hdr = spm_dicom_headers(P)
% P   - array of filenames
% hdr - cell array of headers, one element for each file.
%
% Contents of headers are approximately explained in:
% http://medical.nema.org/dicom/2001.html
%
% This code will not work for all cases of DICOM data, as DICOM is an
% extremely complicated "standard".
%
%_______________________________________________________________________
% @(#)spm_dicom_headers.m	2.22 John Ashburner 05/01/19

ver = sscanf(version,'%d');
if ver<6, error('Need Matlab 6.0 or higher for this function.'); end;

dict = readdict;
j    = 0;
hdr  = {};
if size(P,1)>1, spm_progress_bar('Init',size(P,1),'Reading DICOM headers','Files complete'); end;
for i=1:size(P,1),
	tmp = readdicomfile(P(i,:),dict);
	if ~isempty(tmp),
		j      = j + 1;
		hdr{j} = tmp;
	end;
	if size(P,1)>1, spm_progress_bar('Set',i); end;
end;
if size(P,1)>1, spm_progress_bar('Clear'); end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function ret = readdicomfile(P,dict)
ret = [];
P   = deblank(P);
fp  = fopen(P,'r','ieee-le');
if fp==-1, warning(['Cant open "' P '".']); return; end;

fseek(fp,128,'bof');
dcm = fread(fp,4,'*char')';
if ~strcmp(dcm,'DICM'),
	% Try truncated DICOM file fomat
	fseek(fp,0,'bof');
	tag.group   = fread(fp,1,'ushort');
	tag.element = fread(fp,1,'ushort');
	%t          = dict.tags(tag.group+1,tag.element+1);
	t           = find(dict.group==tag.group & dict.element==tag.element);
	if isempty(t),  % entry not found in DICOM dict
		fclose(fp);
		warning(['"' P '" is not a DICOM file.']);
		return;
	else
		fseek(fp,0,'bof');
	end;
end;
ret = read_dicom(fp, 'il',dict);
ret.Filename = fopen(fp);
fclose(fp);
return;
%_______________________________________________________________________

%_______________________________________________________________________
function [ret,len] = read_dicom(fp, flg, dict,lim)
if nargin<4, lim=Inf; end;
%if lim==2^32-1, lim=Inf; end;
len = 0;
ret = [];
tag = read_tag(fp,flg,dict);
while ~isempty(tag) && ~(tag.group==65534 && tag.element==57357), % && tag.length==0),
	%fprintf('%.4x/%.4x %d\n', tag.group, tag.element, tag.length);
	if tag.length>0,
		switch tag.name,
		case {'GroupLength'},
			% Ignore it
			fseek(fp,tag.length,'cof');
		case {'PixelData'},
			ret.StartOfPixelData = ftell(fp);
			ret.SizeOfPixelData  = tag.length;
			ret.VROfPixelData    = tag.vr;
			fseek(fp,tag.length,'cof');
		case {'CSAData'}, % raw data
			ret.StartOfCSAData = ftell(fp);
			ret.SizeOfCSAData = tag.length;
			fseek(fp,tag.length,'cof');
		case {'CSAImageHeaderInfo', 'CSASeriesHeaderInfo','Private_0029_1210','Private_0029_1220'},
			dat  = decode_csa(fp,tag.length);
			ret.(tag.name) = dat;
		case {'TransferSyntaxUID'},
			dat = fread(fp,tag.length,'*char')';
			dat = deblank(dat);
			ret.(tag.name) = dat;
			switch dat,
			case {'1.2.840.10008.1.2'},      % Implicit VR Little Endian
				flg = 'il';
			case {'1.2.840.10008.1.2.1'},    % Explicit VR Little Endian
				flg = 'el';
			case {'1.2.840.10008.1.2.1.99'}, % Deflated Explicit VR Little Endian
				warning(['Cant read Deflated Explicit VR Little Endian file "' fopen(fp) '".']);
				flg = 'dl';
				return;
			case {'1.2.840.10008.1.2.2'},    % Explicit VR Big Endian
				%warning(['Cant read Explicit VR Big Endian file "' fopen(fp) '".']);
				flg = 'eb';
			otherwise,
				warning(['Unknown Transfer Syntax UID for "' fopen(fp) '".']);
				return;
			end;
		otherwise,
			switch tag.vr,
			case {'UN'},
				% Unknown - read as char
				dat = fread(fp,tag.length,'char')';
			case {'AE', 'AS', 'CS', 'DA', 'DS', 'DT', 'IS', 'LO', 'LT',...
				  'PN', 'SH', 'ST', 'TM', 'UI', 'UT'},
				% Character strings
				dat = fread(fp,tag.length,'*char')';

				switch tag.vr,
				case {'UI','ST'},
					dat = deblank(dat);
				case {'DS'},
					dat = strread(dat,'%f','delimiter','\\')';
				case {'IS'},
					dat = strread(dat,'%d','delimiter','\\')';
				case {'DA'},
					dat     = strrep(dat,'.',' ');
					[y,m,d] = strread(dat,'%4d%2d%2d');
					dat     = datenum(y,m,d);
				case {'TM'},
					if any(dat==':'),
						[h,m,s] = strread(dat,'%d:%d:%f');
					else
						[h,m,s] = strread(dat,'%2d%2d%f');
					end;
					if isempty(h), h = 0; end;
					if isempty(m), m = 0; end;
					if isempty(s), s = 0; end;
					dat = s+60*(m+60*h);
				otherwise,
				end;
			case {'OB'},
				% dont know if this should be signed or unsigned
				dat = fread(fp,tag.length,'char')';
			case {'US', 'AT', 'OW'},
				dat = fread(fp,tag.length/2,'uint16')';
			case {'SS'},
				dat = fread(fp,tag.length/2,'int16')';
			case {'UL'},
				dat = fread(fp,tag.length/4,'uint32')';
			case {'SL'},
				dat = fread(fp,tag.length/4,'int32')';
			case {'FL'},
				dat = fread(fp,tag.length/4,'float')';
			case {'FD'},
				dat = fread(fp,tag.length/8,'double')';
			case {'SQ'},
				[dat,len1] = read_sq(fp, flg,dict,tag.length);
				tag.length = len1;
			otherwise,
				dat = '';
				fseek(fp,tag.length,'cof');
				warning(['Unknown VR "' tag.vr '" in "' fopen(fp) '".']);
			end;
			ret.(tag.name) = dat;
		end;
	end;
	len = len + tag.le + tag.length;
	if len>=lim, return; end;
	tag = read_tag(fp,flg,dict);
end;
if ~isempty(tag),
	len = len + tag.le;

	% I can't find this bit in the DICOM standard, but it seems to
	% be needed for Philips Integra
	if tag.group==65534 && tag.element==57357 && tag.length~=0,
		fseek(fp,-4,'cof');
		len = len-4;
	end;
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function [ret,len] = read_sq(fp, flg, dict,lim)
ret = {};
n   = 0;
len = 0;
while len<lim,
	tag.group   = fread(fp,1,'ushort');
	tag.element = fread(fp,1,'ushort');
	tag.length  = fread(fp,1,'uint');
	if isempty(tag.length), return; end;

	%if tag.length == 2^32-1, % FFFFFFFF
		%tag.length = Inf;
	%end;
	if tag.length==13, tag.length=10; end;

	len         = len + 8;
	if (tag.group == 65534) && (tag.element == 57344), % FFFE/E000
		[Item,len1] = read_dicom(fp, flg, dict, tag.length);
		len    = len + len1;
		n      = n + 1;
		ret{n} = Item;
	elseif (tag.group == 65279) && (tag.element == 224), % FEFF/00E0
		% Byte-swapped
		[fname,perm,fmt] = fopen(fp);
		flg1 = flg;
		if flg(2)=='b',
			flg1(2) = 'l';
		else
			flg1(2) = 'b';
		end;
		[Item,len1] = read_dicom(fp, flg1, dict, tag.length);
		len    = len + len1;
		n      = n + 1;
		ret{n} = Item;
		pos    = ftell(fp);
		fclose(fp);
		fp     = fopen(fname,perm,fmt); 
		fseek(fp,pos,'bof');
	elseif (tag.group == 65534) && (tag.element == 57565), % FFFE/E0DD
		break;
	elseif (tag.group == 65279) && (tag.element == 56800), % FEFF/DDE0
		% Byte-swapped
		break;
	else
		warning([num2str(tag.group) '/' num2str(tag.element) ' unexpected.']);
	end;
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function tag = read_tag(fp,flg,dict)
tag.group   = fread(fp,1,'ushort');
tag.element = fread(fp,1,'ushort');
if isempty(tag.element), tag=[]; return; end;
if tag.group == 2, flg = 'el'; end;
%t          = dict.tags(tag.group+1,tag.element+1);
t           = find(dict.group==tag.group & dict.element==tag.element);
if t>0,
	tag.name = dict.values(t).name;
	tag.vr   = dict.values(t).vr{1};
else
	tag.name = sprintf('Private_%.4x_%.4x',tag.group,tag.element);
	tag.vr   = 'UN';
end;

if flg(2) == 'b',
	[fname,perm,fmt] = fopen(fp);
	if strcmp(fmt,'ieee-le'),
		pos = ftell(fp);
		fclose(fp);
		fp  = fopen(fname,perm,'ieee-be');
		fseek(fp,pos,'bof');
	end;
end;

if flg(1) =='e',
	tag.vr      = fread(fp,2,'*char')';
	tag.le      = 6;
	switch tag.vr,
	case {'OB','OW','SQ','UN','UT'}
		if ~strcmp(tag.vr,'UN') || tag.group~=65534,
			fseek(fp,2,0);
		end;
		tag.length = double(fread(fp,1,'uint'));
		tag.le     = tag.le + 6;
	case {'AE','AS','AT','CS','DA','DS','DT','FD','FL','IS','LO','LT','PN','SH','SL','SS','ST','TM','UI','UL','US'},
		tag.length = double(fread(fp,1,'ushort'));
		tag.le     = tag.le + 2;
	otherwise,
		fseek(fp,2,0);
		tag.length = double(fread(fp,1,'uint'));
		tag.le     = tag.le + 6;
	end;
else
	tag.le =  8;
	tag.length = double(fread(fp,1,'uint'));
end;
if isempty(tag.vr) || isempty(tag.length),
	tag = [];
	return;
end;


if rem(tag.length,2),
	if tag.length==4294967295,
		tag.length = Inf;
		return;
	elseif tag.length==13,
		% disp(['Whichever manufacturer created "' fopen(fp) '" is taking the p***!']);
		% For some bizarre reason, known only to themselves, they confuse lengths of
		% 13 with lengths of 10.
		tag.length = 10;
	else
		warning(['Unknown odd numbered Value Length (' sprintf('%x',tag.length) ') in "' fopen(fp) '".']);
		tag = [];
	end;
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function dict = readdict
dict = load('spm_dicom_dict.mat');
return;
%_______________________________________________________________________

%_______________________________________________________________________
function dict = readdict_txt
file = textread('spm_dicom_dict.txt','%s','delimiter','\n','whitespace','');
clear values
i = 0;
for i0=1:length(file),
	words = strread(file{i0},'%s','delimiter','\t');
	if length(words)>=5 && ~strcmp(words{1}(3:4),'xx'),
		grp = sscanf(words{1},'%x');
		ele = sscanf(words{2},'%x');
		if ~isempty(grp) && ~isempty(ele),
			i          = i + 1;
			group(i)   = grp;
			element(i) = ele;
			vr         = {};
			for j=1:length(words{4})/2,
				vr{j}  = words{4}(2*(j-1)+1:2*(j-1)+2);
			end;
			name       = words{3};
			msk        = find(~(name>='a' & name<='z') & ~(name>='A' & name<='Z') &...
			                  ~(name>='0' & name<='9') & ~(name=='_'));
			name(msk)  = '';
			values(i)  = struct('name',name,'vr',{vr},'vm',words{5});
		end;
	end;
end;

tags = sparse(group+1,element+1,1:length(group));
dict = struct('values',values,'tags',tags);
dict = desparsify(dict);
return;
%_______________________________________________________________________

%_______________________________________________________________________
function dict = desparsify(dict)
[group,element] = find(dict.tags);
offs            = zeros(size(group));
for k=1:length(group),
        offs(k) = dict.tags(group(k),element(k));
end;
dict.group(offs)   = group-1;
dict.element(offs) = element-1;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function t = decode_csa(fp,lim)
% Decode shadow information (0029,1010) and (0029,1020)
[fname,perm,fmt] = fopen(fp);
pos = ftell(fp);
if strcmp(fmt,'ieee-be'),
        fclose(fp);
        fp  = fopen(fname,perm,'ieee-le');
        fseek(fp,pos,'bof');
end;

c   = fread(fp,4,'char');
fseek(fp,pos,'bof');

if all(c'==[83 86 49 48]), % "SV10"
	t = decode_csa2(fp,lim);
else
	t = decode_csa1(fp,lim);
end;

if strcmp(fmt,'ieee-be'),
	fclose(fp);
	fp  = fopen(fname,perm,fmt);
end;
fseek(fp,pos+lim,'bof');
return;
%_______________________________________________________________________

%_______________________________________________________________________
function t = decode_csa1(fp,lim)
n   = fread(fp,1,'uint32');
if n>128 || n < 0,
	fseek(fp,lim-4,'cof');
	t = struct('junk','Don''t know how to read this damned file format');
	return;
end;
xx  = fread(fp,1,'uint32')'; % Unused "M" or 77 for some reason
tot = 2*4;
for i=1:n,
	t(i).name    = fread(fp,64,'char')';
	msk          = find(~t(i).name)-1;
	if ~isempty(msk),
		t(i).name    = char(t(i).name(1:msk(1)));
	else
		t(i).name    = char(t(i).name);
	end;
	t(i).vm      = fread(fp,1,'int32')';
	t(i).vr      = fread(fp,4,'char')';
	t(i).vr      = char(t(i).vr(1:3));
	t(i).syngodt = fread(fp,1,'int32')';
	t(i).nitems  = fread(fp,1,'int32')';
	t(i).xx      = fread(fp,1,'int32')'; % 77 or 205
	tot          = tot + 64+4+4+4+4+4;
	for j=1:t(i).nitems
		% This bit is just wierd
		t(i).item(j).xx  = fread(fp,4,'int32')'; % [x x 77 x]
		len              = t(i).item(j).xx(1)-t(1).nitems;
		if len<0 || len+tot+4*4>lim,
			t(i).item(j).val = '';
			tot              = tot + 4*4;
			break;
		end;
		t(i).item(j).val = fread(fp,len,'*char')';
		fread(fp,4-rem(len,4),'char');
		tot              = tot + 4*4+len+(4-rem(len,4));
	end;
end;
return;
%_______________________________________________________________________

%_______________________________________________________________________
function t = decode_csa2(fp,lim)
c   = fread(fp,4,'char'); % Unused
n   = fread(fp,4,'char'); % Unused
n   = fread(fp,1,'uint32');
if n>128 || n < 0,
	fseek(fp,lim-4,'cof');
	t = struct('junk','Don''t know how to read this damned file format');
	return;
end;
xx  = fread(fp,1,'uint32')'; % Unused "M" or 77 for some reason
for i=1:n,
	t(i).name    = fread(fp,64,'char')';
	msk          = find(~t(i).name)-1;
	if ~isempty(msk),
		t(i).name    = char(t(i).name(1:msk(1)));
	else
		t(i).name    = char(t(i).name);
	end;
	t(i).vm      = fread(fp,1,'int32')';
	t(i).vr      = fread(fp,4,'char')';
	t(i).vr      = char(t(i).vr(1:3));
	t(i).syngodt = fread(fp,1,'int32')';
	t(i).nitems  = fread(fp,1,'int32')';
	t(i).xx      = fread(fp,1,'int32')'; % 77 or 205
	for j=1:t(i).nitems
		t(i).item(j).xx  = fread(fp,4,'int32')'; % [x x 77 x]
		len              = t(i).item(j).xx(2);
		t(i).item(j).val = fread(fp,len,'*char')';
		fread(fp,rem(4-rem(len,4),4),'char');
	end;
end;
return;
%_______________________________________________________________________
