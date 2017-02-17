function [ data,data_hour ] = simfyf( has_com, fengbi )
%code by fyf xdu 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%参数设置
%全连通1 0
%半连通1 2
%不连通1 3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    roads=[];
    roads_end=400;
    com_end=340;
    %%%%% 深圳工作日
    %car_time=[193 144 144 160 128 80 257 850 706 685 594 497 337 497 674 786 882 1123 1171 738 658 529 337 273];
    %%%%% 深圳双休
    car_time=[162 128 132 139 104 81 58 174 343 489 696 654 550 626 684 761 654 668 557 487 480 468 343 220];
    data=[];
    data_hour=[];

    init();
    max_hour=24;
    for hour=1:max_hour
        for minu=1:60
            fprintf('%d:%d\n',hour,minu);
            for sec=1:60
                if(rand()<car_time(hour)/3600)
                    input_cars(1);    %车辆进入
                    if(fengbi==3&rand()<1/20)
                        init_car(ceil(rand()*8),200)
                    end
                end
                change_pos();   %每辆车行走
                change_dir();   %拐弯
                count_num();    %计数
            end
        end
%         debug_()
    end
    draw_();                %画图
    
%     function sumn= debug_()
%         sumn=0;
%        for i=1:8
%            for j=1:roads_end
%               if(roads(i,j).has_car)
%                   sumn=sumn+1;
%               end
%            end
%        end
%        for i=9:12
%            for j=1:com_end
%               if(roads(i,j).has_car)
%                   sumn=sumn+1;
%               end
%            end
%        end
%     end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    function init()
        for i=1:8
            for j=1:410
                roads(i,j).speed=8;     %速度
                roads(i,j).to_turn=0;   %转弯方向
                roads(i,j).dis=1;       %目的
                roads(i,j).src=1;       %出发
                roads(i,j).turned=0;    %是否已拐弯
                roads(i,j).has_car=0;   %当前位置是否有车
                roads(i,j).moved=0;     %一次过程 是否已经移动过
                roads(i,j).stay_to_turn=0;      %堵车而停留
            end
        end
        if(has_com)
           for i=9:12
               for j=1:340
                    roads(i,j).speed=8;
                    roads(i,j).to_turn=0;
                    roads(i,j).dis=1;
                    roads(i,j).src=1;
                    roads(i,j).turned=0;
                    roads(i,j).has_car=0;
                    roads(i,j).moved=0;   
                    roads(i,j).stay_to_turn=0;
               end
           end
        end
    end
%%%%%%%%%%%%%%%%%%%
function clearm()
    for i=1:8
        for j=1:roads_end
            roads(i,j).moved=0;
        end
    end
    for i=9:12
       for j=1:com_end
          roads(i,j).moved=0;
       end
    end
end
%%%%%%%%%%%%%%%%%%%
    function init_car(index,j)
        roads(index,j).speed=ceil(4+8*rand());
        roads(index,j).to_turn=floor(rand()*3);
        roads(index,j).dis=1;
        roads(index,j).src=index;
        roads(index,j).turned=0;
        roads(index,j).has_car=1;
        roads(index,j).moved=0;
        roads(index,j).stay_to_turn=0;
    end
%%%%%%%
    function input_cars(cars)
        for i=1:cars
            init_car(ceil(mod(rand()*100,8)),1); 
        end
    end
%%%%%%%%%%%%%%%%%%%
    function copy_(src_i,src_j,tar_i,tar_j)
        roads(tar_i, tar_j)=roads(src_i, src_j);
    end
%%%%%%%%%%%%%%%%%%%
    function final_pos=find_max_pos(num,pos)
        if(num<9)
            tmp_end=roads_end;
        else
            tmp_end=com_end;
        end
        final_pos=0;
        for i=1:12
           if(pos+i>tmp_end)
               return;
           end
           if(roads(num,pos+i).has_car)
               final_pos=i-1;
               return ;
           else
               final_pos=i;
           end
        end
    end
%%%%%%%%%
    function gogogo(num,pos)
        
        if(num<9)
            tmp_end=roads_end;
        elseif(num<13)
            tmp_end=com_end;
        end
        
        ideal=find_max_pos(num,pos);
%         if(ideal<roads(num, pos).speed)
%             ideal=roads(num, pos).speed;
%         else
%             roads(num, pos).speed=ideal;
%         end
        roads(num, pos).speed=ideal;
        tar=ideal+pos;
        if (tar>tmp_end) 
           roads(num, pos).has_car=0;
           return ;
        end
        for i=pos+1:tar
           if(roads(num, i).has_car)
               copy_(num, pos, num, i-1);
               roads(num, pos).has_car=0;
               roads(num, i-1).speed=floor(roads(num, i).speed-2*rand());
               if(roads(num, i-1).speed<=0)
                   roads(num, i-1).speed=1;
               end
               roads(num, pos).has_car=0;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
               return ;
           end
        end
        copy_(num, pos, num, tar);
        roads(num, pos).has_car=0;
        if(roads(num, tar).speed<=0)
           roads(num, tar).speed=1;
        end
    end
%%%%%%%
    function change_pos()
        for i=1:8
            for j=1:400
                if(roads(i,j).has_car & ~roads(i,j).moved & ~roads(i,j).stay_to_turn)
                    roads(i,j).moved=1;
                    gogogo(i,j);
                end
            end
        end
        if(has_com)
            for i=9:12
                for j=1:com_end
                    if(roads(i,j).has_car & ~roads(i,j).moved & ~roads(i,j).stay_to_turn)
                        roads(i,j).moved=1;
                        gogogo(i,j);
                    end
                end
            end
        end
        clearm();
    end
%%%%%%%%%%%%%%%%%%%
    function des_j=get_des_pos(src,src_j,pos,dir)
        des_j=src_j;
        if(pos==0)
            if(((src<=4&mod(src,2)==0)|(src>4)&mod(src,2)==1))
                if(dir==1)
                    des_j=roads_end-des_j;
                end
            else
                if(dir==2)
                    des_j=roads_end-des_j;
                end
            end
        elseif(pos==1)
            if(((src<=4&mod(src,2)==0)|(src>4)&mod(src,2)==1))
                if(dir==2)
                    des_j=roads_end-des_j;
                end
            else
                if(dir==1)
                    des_j=roads_end-des_j;
                end
            end
        elseif(pos==2)
            des_j=1;
        elseif(pos==3)
            des_j=src_j;
        elseif(pos==4)
            des_j=200;
        end
    end
%%%%%%%%
    function turn_by_law(i,j,pos)
        if(pos==0)
            law=[3 7;3 7;6 2;6 2;8 4;8 4;1 5;1 5];
        elseif(pos==1)
            law=[4 8;4 8;5 1;5 1;7 3;7 3;6 2;6 2];
        elseif(pos==2)
            law=[0 12;10 0;0 9;11 0;12 0;0 10;9 0;0 11];
        elseif(pos==3)
            law=[10 12;11 9;12 10;9 11];
        elseif(pos==4)
            law=[4 8;5 1;7 3;2 6];
        end
        src=i;
        if(pos>=3)
            des=law(i-8,roads(i,j).to_turn);
        else
            des=law(i,roads(i,j).to_turn);
        end
        
        if(fengbi==2)
           if(des==10|des==12)
               return;
           end
        end
        
        if(des==0)
            return;
        end
        roads(src,j).moved=1;
        
        des_j=get_des_pos(src,j,pos,roads(i,j).to_turn);

        if(roads(des,des_j).has_car)
            roads(src,j).stay_to_turn=1;
        else
            roads(src,j).stay_to_turn=0;
            copy_(src,j,des,des_j);
            roads(src,j).has_car=0;
            if(pos==4)
               init_car(des,des_j-1) 
            end
        end
    end
%%%%%%%%%%%
    function change_dir()
        for i=1:8
            for j=30:40
                if(roads(i,j).has_car & ~roads(i,j).moved & roads(i,j).to_turn)
                   turn_by_law(i,j,0); 
                end
                roads(i,j).to_turn=floor(rand()*3);                 %下个路口
            end
            for j=360:370
                if(roads(i,j).has_car & ~roads(i,j).moved & roads(i,j).to_turn)
                   turn_by_law(i,j,1); 
                end
                roads(i,j).to_turn=floor(rand()*3);
            end
            if(has_com)
                for j=195:205
                    if(roads(i,j).has_car & ~roads(i,j).moved & roads(i,j).to_turn)
                       turn_by_law(i,j,2); 
                    end
                    roads(i,j).to_turn=floor(rand()*3);
                end
            end
        end
        if(has_com)
           for i=9:12
              for j=165:175
                  if(roads(i,j).has_car & ~roads(i,j).moved & roads(i,j).to_turn)
                       turn_by_law(i,j,3); 
                  end
                  roads(i,j).to_turn=floor(rand()*3);
              end
              for j=330:340
                  if(roads(i,j).has_car & ~roads(i,j).moved & roads(i,j).to_turn)
                       turn_by_law(i,j,4); 
                  end
                  roads(i,j).to_turn=floor(rand()*3);
              end
           end
        end
        clearm();
    end
%%%%%%%%%%%%%%%%%%
    function count=count_seg(i)
        count=0;
        for j=290:310
            if(roads(i,j).has_car)
               count=count+1; 
            end
        end
    end
%%%%%%%%
    function count_num()
        for i=1:8
            data(hour,minu,sec,i)=count_seg(i);
        end
    end
%%%%%%%%%%%%%%%%%
    function draw_()
        data_hour=zeros(max_hour,8);
        for h=1:max_hour
            for ind=1:8
                for m=1:60
                    for s=1:60
                        data_hour(h,ind)=data_hour(h,ind)+data(h,m,s,ind); 
                    end
                end
            end
        end
        data_hour(:,9)=sum(data_hour,2);
    end
    
end





