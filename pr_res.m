clc
clearvars
warning off
load DATA/p_2015.mat
load DATA\SRTM.mat
load DATA\mask_piemonte_high.mat

region_str = "piemonte";
[region,  ~    , conf_mi, conf_ma] = region_select(region_str);
[a1 b1] = meshgrid([1:300],[1:365]);
[a b] = meshgrid([1:300],[1:365]);


f2 = figure;
f2.Position = [90 90 1200 600];

k = 0;
for i = 1:1

    ele = elevation_calibration(:)';
    lat = latitude_calibration(:)';
    lon = longitude_calibration(:)';
    c = error_calibration(1:365,:);

    idxgood=~isnan(c);
    CI = griddata( a1(idxgood),b1(idxgood),c(idxgood), a, b,'nearest') ;

    fin = cat(1,CI,ele,lat,lon);
    fin(:,isnan(ele)) = [];
    fin = transpose(fin);

    fin = sortrows(fin,size(fin,2)-2);
    fin = transpose(fin);

    fin(:,fin(end-2,:)<0 | fin(end-2,:)>4000) = [];
    fini = fin;


    fin([end-2:end],:) = [];
    %     fin = fin - mean(fin,'all','omitnan');


    hg = mean(fin,2,'omitnan');
    ha = mean(abs(fin),2,'omitnan');
    hs = std(fin,[],2,'omitnan');
    for h=1:size(fin,1)-1
        if h == 1
            patch([(k+h-1) (k+h) (k+h) (k+h-1)], [hg(h) hg(h+1) hg(h)+hs(h) hg(h+1)+hs(h+1)],[0.46,0.79,0.53],'EdgeColor','none','DisplayName','STD giornaliera')
            hold on
            patch([(k+h-1) (k+h) (k+h) (k+h-1)], [hg(h) hg(h+1) hg(h)-hs(h) hg(h+1)-hs(h+1)],[0.46,0.79,0.53],'EdgeColor','none','HandleVisibility','off')
        else
            patch([(k+h-1) (k+h) (k+h) (k+h-1)], [hg(h) hg(h+1) hg(h)+hs(h) hg(h+1)+hs(h+1)],[0.46,0.79,0.53],'EdgeColor','none','HandleVisibility','off')
            hold on
            patch([(k+h-1) (k+h) (k+h) (k+h-1)], [hg(h) hg(h+1) hg(h)-hs(h) hg(h+1)-hs(h+1)],[0.46,0.79,0.53],'EdgeColor','none','HandleVisibility','off')
        end
    end
    for j=1:size(fin,2)
        if j ==1
            scatter([k:k+size(fin,1)-1],movmean(fin(:,j),1,'omitnan'),3,'r','filled','MarkerFaceAlpha',0.5,'DisplayName','Single day/station BIAS')
            hold on
        else
            scatter([k:k+size(fin,1)-1],movmean(fin(:,j),1,'omitnan'),3,'r','filled','MarkerFaceAlpha',0.5,'HandleVisibility','off')
        end
    end
    plot([k:k+size(fin,1)-1],hg,'k','LineWidth',2,'DisplayName','BIAS medio giornaliero')
    plot([k:k+size(fin,1)-1],ha,'b','LineWidth',2,'DisplayName','MAE giornaliero')
    k = k+size(fin,1);
end
legend('Location','southoutside','Orientation','horizontal')
xticks(linspace(1,360,12))
xticklabels(['Gen';'Feb';'Mar';'Apr';'Mag';'Giu';'Lug';'Ago';'Set';'Ott';'Nov';'Dic'])
ylim([-10 10])
xlim([0 365])
ylabel('Bias [°C]')
xlabel(['Mese'])
set(gca,'FontName','Calibri')
set(gca,'FontSize',13)