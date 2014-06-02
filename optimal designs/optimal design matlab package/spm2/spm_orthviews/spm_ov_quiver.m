function ret = quiver(varargin)
% %W% Volkmar Glauche <glauche@uke.uni-hamburg.de> %E%

global st;
if isempty(st)
  error('quiver: This routine can only be called as a plugin for spm_orthviews!');
end;

if nargin < 2
  error('quiver: Wrong number of arguments. Usage: spm_orthviews(''quiver'', cmd, volhandle, varargin)');
end;

cmd = lower(varargin{1});
volhandle = varargin{2};
switch cmd
  case 'init'     %function addquiver(handle, Vqfnames, Vmaskfname, varargin)
    if nargin < 4
      error('spm_orthviews(''quiver'', ''init'',...): Not enough arguments');
    end;
    Vq = spm_vol(varargin{3});
    Vmask = spm_vol(varargin{4});
    if length(Vq) == 3
      st.vols{volhandle}.quiver = struct('qx',Vq(1),'qy',Vq(2),'qz',Vq(3), ...
	  'mask',Vmask, 'fa',[], 'thresh', [.1 Inf], 'ls','y.', ...
	  'qst',3,'ql',.9,'qht',[],'qhc',[],'qhs',[], 'qw', .5);
    else
      error('spm_orthviews(''quiver'', ''init'',...): Please specify 3 images!');
    end;
    if nargin > 4
      if ~isempty(varargin{5})
	st.vols{volhandle}.quiver.fa = spm_vol(varargin{5});
      end;
    end;
    if nargin > 5
      if ~isempty(varargin{6})
	st.vols{volhandle}.quiver.thresh(1) = varargin{6};
      end;
    end;
    if nargin > 6
      if ~isempty(varargin{7})
	st.vols{volhandle}.quiver.thresh(2) = varargin{7};
      end;
    end;
    if nargin > 7
      if isstr(varargin{8})
	st.vols{volhandle}.quiver.ls = varargin{8};
      end;
    end;
    if nargin > 8
      if ~isempty(varargin{9})
	st.vols{volhandle}.quiver.qst = varargin{9};
      end;
    end;
    if isempty(st.vols{volhandle}.quiver.fa)
      st.vols{volhandle}.quiver.ql = .35;
    end;
    if nargin > 9
      if ~isempty(varargin{10})
	st.vols{volhandle}.quiver.ql = varargin{10};
      end;
    end;
    if nargin > 10
      if ~isempty(varargin{11})
	st.vols{volhandle}.quiver.qw = varargin{11};
      end;
    end;
    
  case 'redraw'
    TM0 = varargin{3};
    TD  = varargin{4};
    CM0 = varargin{5};
    CD  = varargin{6};
    SM0 = varargin{7};
    SD  = varargin{8};
    if isfield(st.vols{volhandle},'quiver')
      % need to delete old quiver lines before redrawing
      delete(st.vols{volhandle}.quiver.qht);
      delete(st.vols{volhandle}.quiver.qhc);
      delete(st.vols{volhandle}.quiver.qhs);
      
      qx  = st.vols{volhandle}.quiver.qx;
      qy  = st.vols{volhandle}.quiver.qy;
      qz  = st.vols{volhandle}.quiver.qz;
      mask = st.vols{volhandle}.quiver.mask;
      fa = st.vols{volhandle}.quiver.fa;
      thresh(1) = st.vols{volhandle}.quiver.thresh(1);
      thresh(2) = st.vols{volhandle}.quiver.thresh(2);
      ls = st.vols{volhandle}.quiver.ls;
      
      % step size for selection of locations
      prm = spm_imatrix(st.Space);
      qst = ceil(st.vols{volhandle}.quiver.qst/prm(7)); 
      ql = st.vols{volhandle}.quiver.ql; % scaling of arrow length
      qst1 = ceil(qst/2);
      
      Mx   = st.vols{volhandle}.premul*qx.mat;
      My   = st.vols{volhandle}.premul*qy.mat;
      Mz   = st.vols{volhandle}.premul*qz.mat;
      Mm   = st.vols{volhandle}.premul*mask.mat;
      if ~isempty(fa)
	fat = spm_slice_vol(fa,inv(TM0*(st.Space\Mx)),TD,0)';
      else
	fat = 1;
      end;
      rqt = cat(3, spm_slice_vol(qx,inv(TM0*(st.Space\Mx)),TD,0)', ...
	  spm_slice_vol(qy,inv(TM0*(st.Space\My)),TD,0)', ...
	  spm_slice_vol(qz,inv(TM0*(st.Space\Mz)),TD,0)');
      rqt = st.Space(1:3,1:3)*st.vols{volhandle}.premul(1:3,1:3)*reshape(rqt,TD(1)*TD(2),3)';
      qxt = fat.*reshape(rqt(1,:)',TD(2),TD(1));
      qyt = fat.*reshape(rqt(2,:)',TD(2),TD(1));
      qzt = fat.*reshape(rqt(3,:)',TD(2),TD(1));
      
      maskt = spm_slice_vol(mask,inv(TM0*(st.Space\Mm)),TD,0)';
      xt = [1:TD(1)]-.5; 
      yt = [1:TD(2)]-.5;
      zt = zeros(size(qxt));
      zt((maskt < thresh(1))|(maskt > thresh(2))) = NaN;
      zt((qxt == 0) & (qyt == 0) & (qzt == 0)) = NaN;
      
      if ~isempty(fa)
	fac = spm_slice_vol(fa,inv(CM0*(st.Space\Mx)),CD,0)';
      else
	fac = 1;
      end;
      rqc = cat(3, spm_slice_vol(qx,inv(CM0*(st.Space\Mx)),CD,0)', ...
	  spm_slice_vol(qy,inv(CM0*(st.Space\My)),CD,0)', ...
	  spm_slice_vol(qz,inv(CM0*(st.Space\Mz)),CD,0)');
      rqc = st.Space(1:3,1:3)*st.vols{volhandle}.premul(1:3,1:3)*reshape(rqc,CD(1)*CD(2),3)';
      qxc = fac.*reshape(rqc(1,:)',CD(2),CD(1));
      qyc = fac.*reshape(rqc(2,:)',CD(2),CD(1));
      qzc = fac.*reshape(rqc(3,:)',CD(2),CD(1));
      
      maskc = spm_slice_vol(mask,inv(CM0*(st.Space\Mm)),CD,0)';
      xc = [1:CD(1)]-.5;
      yc = [1:CD(2)]-.5;
      zc = zeros(size(qxc));
      zc((maskc < thresh(1))|(maskc > thresh(2))) = NaN;
      zc((qxc == 0) & (qyc == 0) & (qzc == 0)) = NaN;            
      
      if ~isempty(fa)
	fas = spm_slice_vol(fa,inv(SM0*(st.Space\Mx)),SD,0)';
      else
	fas = 1;
      end;   
      rqs = cat(3, spm_slice_vol(qx,inv(SM0*(st.Space\Mx)),SD,0)', ...
	  spm_slice_vol(qy,inv(SM0*(st.Space\My)),SD,0)', ...
	  spm_slice_vol(qz,inv(SM0*(st.Space\Mz)),SD,0)');
      rqs = st.Space(1:3,1:3)*st.vols{volhandle}.premul(1:3,1:3)*reshape(rqs,SD(1)*SD(2),3)';
      qxs = fas.*reshape(rqs(1,:)',SD(2),SD(1));
      qys = fas.*reshape(rqs(2,:)',SD(2),SD(1));
      qzs = fas.*reshape(rqs(3,:)',SD(2),SD(1));
      
      masks = spm_slice_vol(mask,inv(SM0*(st.Space\Mm)),SD,0)';
      xs = [1:SD(1)]-.5;
      ys = [1:SD(2)]-.5;
      zs = zeros(size(qxs));
      zs((masks < thresh(1))|(masks > thresh(2))) = NaN;
      zs((qxs == 0) & (qys == 0) & (qzs == 0)) = NaN;
      
      % check for availability of "centered" quiver function
      if exist('spm_orthviews/quiver3') == 2
	quiverfun = 'spm_orthviews/quiver3';
      else % fallback
	quiverfun = 'quiver3';
	warning('Function "dti_quiver3.m" not found!\n Using standard Matlab routine "quiver3.m" instead.\n This may not give  nice quiver plots.');
      end;
      % transversal - plot (x y z)
      np = get(st.vols{volhandle}.ax{1}.ax,'NextPlot');
      set(st.vols{volhandle}.ax{1}.ax,'NextPlot','add');
      axes(st.vols{volhandle}.ax{1}.ax);
      st.vols{volhandle}.quiver.qht = feval(quiverfun,xt(qst1:qst:end),...
	  yt(qst1:qst:end), zt(qst1:qst:end,qst1:qst:end), ...
	  qxt(qst1:qst:end,qst1:qst:end),...
	  qyt(qst1:qst:end,qst1:qst:end),...
	  qzt(qst1:qst:end,qst1:qst:end),ql,ls);
      set(st.vols{volhandle}.ax{1}.ax,'NextPlot',np);
      set(st.vols{volhandle}.quiver.qht, ...
	  'Parent',st.vols{volhandle}.ax{1}.ax, 'HitTest','off', ...
	  'Linewidth',st.vols{volhandle}.quiver.qw );
      
      % coronal - plot (x z y)
      np = get(st.vols{volhandle}.ax{2}.ax,'NextPlot');
      set(st.vols{volhandle}.ax{2}.ax,'NextPlot','add');
      axes(st.vols{volhandle}.ax{2}.ax);
      st.vols{volhandle}.quiver.qhc = feval(quiverfun,xc(qst1:qst:end),...
	  yc(qst1:qst:end), zc(qst1:qst:end,qst1:qst:end), ...
	  qxc(qst1:qst:end,qst1:qst:end), ...
	  qzc(qst1:qst:end,qst1:qst:end), ...
	  qyc(qst1:qst:end,qst1:qst:end),ql, ls);
      set(st.vols{volhandle}.ax{2}.ax,'NextPlot',np);
      set(st.vols{volhandle}.quiver.qhc, ...
	  'Parent',st.vols{volhandle}.ax{2}.ax, 'HitTest','off', ... 
	  'Linewidth',st.vols{volhandle}.quiver.qw );
      
      % sagittal - plot (-y z x)
      np = get(st.vols{volhandle}.ax{3}.ax,'NextPlot');
      set(st.vols{volhandle}.ax{3}.ax,'NextPlot','add');
      axes(st.vols{volhandle}.ax{3}.ax);
      st.vols{volhandle}.quiver.qhs = feval(quiverfun,xs(qst1:qst:end),...
	  ys(qst1:qst:end), zs(qst1:qst:end,qst1:qst:end), ...
	  -qys(qst1:qst:end,qst1:qst:end), ...
	  qzs(qst1:qst:end,qst1:qst:end), ...
	  qxs(qst1:qst:end,qst1:qst:end),ql,ls);
      set(st.vols{volhandle}.ax{3}.ax,'NextPlot',np);
      set(st.vols{volhandle}.quiver.qhs, ...
	  'Parent',st.vols{volhandle}.ax{3}.ax, 'HitTest','off', ... 
	  'Linewidth',st.vols{volhandle}.quiver.qw );
    end; %quiver
  
  case 'delete'
    if isfield(st.vols{volhandle},'quiver'),
      delete(st.vols{volhandle}.quiver.qht);
      delete(st.vols{volhandle}.quiver.qhc);
      delete(st.vols{volhandle}.quiver.qhs);
      st.vols{volhandle} = rmfield(st.vols{volhandle},'quiver');
    end;
  %-------------------------------------------------------------------------
  % Context menu and callbacks
  case 'context_menu'  
    item0 = uimenu(varargin{3}, 'Label', 'Quiver');
      item1 = uimenu(item0, 'Label', 'Add', 'Callback', ...
	  ['feval(''spm_ov_quiver'',''context_init'', ', ...
	    num2str(volhandle), ');'], 'Tag', ['QUIVER_0_', num2str(volhandle)]);
      item2 = uimenu(item0, 'Label', 'Properties', ...
	  'Visible', 'off', 'Tag', ['QUIVER_1_', num2str(volhandle)]);
        item2_1 = uimenu(item2, 'Label', 'Mask threshold', 'Callback', ...
	    ['feval(''spm_ov_quiver'',''context_edit'',', ...
	      num2str(volhandle), ',''thresh'');']);
	item2_2 = uimenu(item2, 'Label', 'Linestyle', 'Callback', ...
	    ['feval(''spm_ov_quiver'',''context_edit'',', ...
	      num2str(volhandle), ',''ls'');']);
	item2_3 = uimenu(item2, 'Label', 'Quiver distance', 'Callback', ...
	    ['feval(''spm_ov_quiver'',''context_edit'',', ...
	      num2str(volhandle), ',''qst'');']); 
	item2_4 = uimenu(item2, 'Label', 'Quiver length', 'Callback', ...
	    ['feval(''spm_ov_quiver'',''context_edit'',', ...
	      num2str(volhandle), ',''ql'');']); 
	item2_5 = uimenu(item2, 'Label', 'Linewidth', 'Callback', ...
	    ['feval(''spm_ov_quiver'',''context_edit'',', ...
	      num2str(volhandle), ',''qw'');']); 
      item3 = uimenu(item0, 'Label', 'Remove', 'Callback', ...
	  ['feval(''spm_ov_quiver'',''context_delete'', ', ...
	    num2str(volhandle), ');'], 'Visible', 'off', ...
	  'Tag', ['QUIVER_1_', num2str(volhandle)]);

  case 'context_init'
    Finter = spm_figure('FindWin', 'Interactive');
    spm_figure('Clear', Finter);
    Vqfnames = spm_get(3,'evec1*.img','Components of 1st eigenvector');
    Vmaskfname = spm_get(1,'*.img','Mask image');
    Vfafname = spm_get(Inf,'fa*.img','Fractional anisotropy image');
    feval('spm_ov_quiver','init',volhandle,Vqfnames,Vmaskfname,Vfafname);
    obj = findobj(0, 'Tag',  ['QUIVER_1_', num2str(volhandle)]);
    set(obj, 'Visible', 'on');
    obj = findobj(0, 'Tag',  ['QUIVER_0_', num2str(volhandle)]);
    set(obj, 'Visible', 'off');
    spm_orthviews('redraw');
  
  case 'context_edit'
    Finter = spm_figure('FindWin', 'Interactive');
    spm_figure('Clear', Finter);
    switch varargin{3}
      case 'thresh'
	in = spm_input('Mask threshold {min max}','!+1','e', ...
	    num2str(st.vols{volhandle}.quiver.thresh), [1 2]);
      case 'ls'
	in = spm_input('Line style','!+1','s', ...
	    st.vols{volhandle}.quiver.ls);
      case 'qst'
	in = spm_input('Quiver distance','!+1','e', ...
	    num2str(st.vols{volhandle}.quiver.qst), 1);
      case 'ql'
	in = spm_input('Quiver length','!+1','e', ...
	    num2str(st.vols{volhandle}.quiver.ql), 1);
      case 'qw'
	in = spm_input('Linewidth','!+1','e', ...
	    num2str(st.vols{volhandle}.quiver.qw), 1);	
    end;
    st.vols{volhandle}.quiver = setfield(st.vols{volhandle}.quiver, ...
	varargin{3}, in);
    spm_orthviews('redraw');
    
  case 'context_delete'
    feval('spm_ov_quiver','delete',volhandle);
    obj = findobj(0, 'Tag',  ['QUIVER_1_', num2str(volhandle)]);
    set(obj, 'Visible', 'off');
    obj = findobj(0, 'Tag',  ['QUIVER_0_', num2str(volhandle)]);
    set(obj, 'Visible', 'on');
   
  otherwise

    fprintf('spm_orthviews(''quiver'',...): Unknown action string %s', cmd);
  end;
  
