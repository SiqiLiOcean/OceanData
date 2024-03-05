%==========================================================================
% OceanData 
%   GTSPP : read GTSPP data (one file)
%
%   Link: https://www.ncei.noaa.gov/data/oceans/gtspp/bestcopy/meds_ascii/
%         https://www.nodc.noaa.gov/GTSPP/document/codetbls/gtsppcode.html
%
% input  :
%   fin    --- input file
%
% output :
%   out    --- struct containing data
%              id    --- UHSLC ID
%              descr --- station description
%              time  --- date and time (datenum)
%              lon   --- longitude (degree east)
%              lat   --- latitude (degree north)
%              t     --- temperature (degree C)
%              s     --- salinity (psu)
%
% Siqi Li, SMAST
% 2023-12-28
%
% Updates:
%
%==========================================================================
function out = GTSPP_read_one(fin, varargin)

read_varargin2(varargin, {'Log'});

out = [];

fid=fopen(fin);

n=0;        % Observation #
% n1=0;       % start line
n2=0;       % end line
ii = 0;     % Observation for output
while (~feof(fid))
    
    if mod(n, 10000)==0 && n>0
        disp(['----' num2str(n)])
    end
    
    % 1----------- Header record
    line=fgetl(fid);
    n=n+1;
    n1=n2+1;
    n2=n1;
    if_TEMP=false;
    if_PSAL=false;
    
    % Location
    lat=str2double(line(63:70));
    lon=-str2double(line(71:79));  
    
    % Date
    year=str2num(line(27:30));
    month=str2num(line(31:32));
    day=str2num(line(33:34));
    hour=str2num(line(35:36));
    minute=str2num(line(37:38));
    
    % Profile header
    clear prof_type
    n_prof=str2num(line(122:123));
    n_segg=zeros(n_prof,1);
    prof_type(1:n_prof,1:4)='-';
    temp = [];
    psal = [];
    for i=1:n_prof
        val_header=line(14*i+117:14*i+130);
        n_segg(i)=str2num(val_header(1:2));
        prof_type(i,:)=val_header(3:6);
        
        if (strcmp(prof_type(i,:),'TEMP'))
            if_TEMP=true;
            nz_TEMP=zeros(n_segg(i),1);
        elseif (strcmp(prof_type(i,:),'PSAL'))
            if_PSAL=true;
            nz_PSAL=zeros(n_segg(i),1);
        end
    end
    
    % 2-----------Profile record
    for i=1:n_prof
        for j=1:n_segg(i)
            line=fgetl(fid);
            n2=n2+1;
            
            profile_type=line(53:56);
            nz=str2num(line(59:62));
            
            data=nan(nz,2);
            for k=1:nz
                s0=63+(k-1)*17+1;
                data(k,1)=str2double(line(s0:s0+5));
                data(k,2)=str2double(line(s0+7:s0+15));
            end
            
            if (strcmp(profile_type,'TEMP'))
                nz_TEMP(j)=nz_TEMP(j)+nz;
                temp=[temp;data];
            elseif (strcmp(profile_type,'PSAL'))
                nz_PSAL(j)=nz_PSAL(j)+nz;
                psal=[psal;data];
            end
        end
    end

    if ~isempty(temp)
        temp(ismember(temp,[0 0], 'rows'),:) = [];
    end
    if ~isempty(psal)
        psal(ismember(psal,[0 0], 'rows'),:) = [];
    end
    
    % % % Output
    % % % Check the xlims
    % % if ~isempty(xlims)
    % %     if xlims(1) <= xlims(2)
    % %         if lon<xlims(1) || lon>xlims(2)
    % %             continue
    % %         end
    % %     else
    % %         if lon>xlims(2) && lon<xlims(1)
    % %             continue
    % %         end
    % %     end
    % % end
    % % % Check the ylims
    % % if ~isempty(ylims)
    % %     if lat>ylims(2) || lat<ylims(1)
    % %         continue
    % %     end
    % % end
    % % % Check the polygon (not support pacific ocean now)
    % % if ~isempty(polygon)
    % %     in = inpolygon(lon, lat, polygon(:,1), polygon(:,2));
    % %     if ~in
    % %         continue
    % %     end
    % % end
    % % % Check the tlims
    % % tt = datenum(year,month,day,hour,minute,0);
    % % if ~isempty(tlims)
    % %     if tt<tlims(1) || tt>tlims(2)
    % %         continue
    % %     end
    % % end
        
    if ~isempty(temp)
        temp(isnan(temp(:,2)),:) = [];
    end
    if ~isempty(psal)
        psal(isnan(psal(:,2)),:) = [];
    end

    if isempty(temp) && isempty(psal)
        continue
    end

    
  
    
    ii = ii + 1;
    tt = datenum(year,month,day,hour,minute,0);
    out(ii).lon=lon;
    out(ii).lat=lat;
    out(ii).time=tt;
    out(ii).id = "GTSPP";
    out(ii).descr = convertCharsToStrings(fin);
    % out(ii).TimeStr=[num2str(year) '-' num2str(month,'%2.2d') '-' num2str(day,'%2.2d') '_' num2str(hour,'%2.2d') ':' num2str(minute,'%2.2d') ':00'];    
    
    if isempty(temp)
        temp = [nan nan];
    end
    if isempty(psal)
        psal = [nan nan];
    end


    z = sort(unique([temp(:,1); psal(:,1)]));
    z(isnan(z)) = [];
    nz = length(z);
    t = nan(nz, 1);
    s = nan(nz, 1);
    for iz = 1 : nz
        t_id = find(temp(:,1)==z(iz));
        s_id = find(psal(:,1)==z(iz));
        if ~isempty(t_id)
            t(iz) = temp(t_id(1), 2);
        end
        if ~isempty(s_id)
            s(iz) = psal(s_id(1), 2);
        end
    end

    out(ii).z = z(:);
    out(ii).t = t(:);
    out(ii).s = s(:);
    
    % % if (if_TEMP)
    % %     [~, I] = sort(temp(:,1));
    % %     out(ii).dep_t=temp(I,1)';
    % %     out(ii).t=temp(I,2)';
    % % else
    % %     out(ii).dep_t=nan;
    % %     out(ii).t=nan;
    % % end
    % % if (if_PSAL)
    % %     [~, I] = sort(psal(:,1));
    % %     out(ii).dep_s=psal(I,1)';
    % %     out(ii).s=psal(I,2)';
    % % else
    % %     out(ii).dep_s=nan;
    % %     out(ii).s=nan;
    % % end
    % Log
    if ~isempty(Log)
        disp(['=======================' num2str(ii,'%6.6d') '========================='])
        disp(['  Line :' num2str(n1) ' to ' num2str(n2)])
        fprintf('%s%10.4f%s%10.4f\n','  Longtidue : ',lon,'    Latitude : ',lat)
        disp(['  Date : ' datestr(tt,'yyyy-mm-dd_HH:MM')])
        % disp( ' | Var  |  NZ  |  Zmin  |  Zmax  |  min   |  max   |' )
        % disp( ' ---------------------------------------------------' )
        % % if (if_TEMP)
        %     fprintf('%s%4d%s%6.1f%s%6.1f%s%6.1f%s%6.1f%s\n',' | TEMP | ',size(temp,1),' | ',min(temp(:,1)),' | ',max(temp(:,1)),' | ',min(temp(:,2)),' | ',max(temp(:,2)),' |')
        % % end
        % % if (if_PSAL)
        %     fprintf('%s%4d%s%6.1f%s%6.1f%s%6.1f%s%6.1f%s\n',' | PSAL | ',size(psal,1),' | ',min(psal(:,1)),' | ',max(psal(:,1)),' | ',min(psal(:,2)),' | ',max(psal(:,2)),' |')
        % % end
        disp( ' |  NZ  |  Zmin  |  Zmax  |  Tmin  |  Tmax  |  Smin  |  Smax  |' )
        disp( ' ---------------------------------------------------------------------' )
        fprintf('%s%4d%s%6.1f%s%6.1f%s%6.1f%s%6.1f%s%6.1f%s%6.1f%s\n', ...
            ' | ',size(temp,1),' | ',min(z),' | ',max(z),' | ', ...
                                     min(t),' | ',max(t),' | ', ...
                                     min(s),' | ',max(s),' |');
    end
    
end

disp('=====================================')
disp(['Output records : ' num2str(ii)])

fclose(fid);
end
        