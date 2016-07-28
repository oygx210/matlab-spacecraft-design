function [newdesign,t_good] = StaticsFill(structures)
% Check each structure, make sure the panels and cylinders can survive
% buckling or not. 

%Edited 6/20/16
%Editor Name: Samuel Wu 
%NetID: scw223

% Initially idealize spacecraft in launch config. as a cantilevered hollow
% cylinder with uniform thickness 

newdesign = structures;

% Get material parameters 
material = MaterialTable();

% Rigidity requirement 
fnat_lat = 10; % Lateral natural frequency (Hz)
fnat_ax = 25; % Axial natural frequency (Hz)

% Factors of safety for ultimate and yielding strength 
fos_ult = 100;
fos_yield = 75;

% Load factors requirement (multiple of weight on Earth)
% May need to change these assumptions
loadf_ax = 6.5;
loadf_lat = 3.0;
loadf_bend = 3.0;

% Pressure requirement (SMAD uses this number for example, change later?)
pressure = 6889;    %(Pa)

MS = 0;
mass = inf;
struct_vol = zeros(1,6);
for i = 1:10;
    % Calculating parameters
    for k = 1:6
    struct_vol(k) = structures.structures(k).Dim(1).*structures.structures(k).Dim(2).*structures.structures(k).Dim(3);
    end
    t_int = structures.structures(1).Dim(1);
    A_const = sum(struct_vol)/t_int;
    mB = structures.componentsMass+2*sum(struct_vol)*material(i).Density;    %inc. allocation for structure
    weight = mB*9.81;
    R = structures.genParameters.satWidth/2;
    
    % Sizing for rigidity
    % Assuming case C & D of SMAD (pg 484) 
    % Axial rigidity
    A_req = (fnat_ax/.250)^2*(mB*R/material(i).E);
    t_ax = A_req/(2*pi*R);
    
    % Lateral rigidity
    I_req = (fnat_lat/.560)^2*(mB*R^3/material(i).E);
    t_lat = I_req/(pi*R^3);
    
    % Calculating limit load of spacecraft
    dist_CG = structures.genParameters.satHeight/2;
    limit_axial = weight*loadf_ax;
    limit_lat = weight*loadf_lat;
    limit_bend = weight*dist_CG*loadf_bend;
    
    % Calculating equivalent axial load: Peq = Paxial + 2M/R
    Peq = limit_axial + 2*limit_bend/R;
    ult_load = Peq*fos_ult;
    yield_load = Peq*fos_yield;

    % Sizing for tensile strength (using A = 2*pi*R*t
    t_ult = Peq/(material(i).F_ult*2*pi*R);
    t_yield = Peq/(material(i).F_yield*2*pi*R);
    t_vect = [t_ult t_yield t_ax t_lat];
    t_req = max(t_vect);
    MS_new = 0;

    % Sizing for stability (compressive strength)
    while MS_new - 1 < 0
        phi = sqrt(R/t_req)/16;
        gamma = 1.0 - 0.901*(1.0-exp(-phi));
        sig_cr = (0.6.*gamma.*material(i).E.*t_req)/R;
        Pcr = 2*pi.*R.*t_req.*sig_cr;
        MS_new = Pcr./ult_load;
        mass_new = A_const.*t_req.*material(i).Density;
        t_req = t_req.*1.05;
    end
    if MS_new >= MS && mass_new < mass 
        mat_i = i;
        MS = MS_new;
        mass = mass_new;
        t_good = t_req./1.05;
    end
end

newdesign.structures(1).Dim(1) = t_good;
newdesign.structures(2).Dim(2) = t_good;
newdesign.structures(3).Dim(2) = t_good;
newdesign.structures(4).Dim(2) = t_good;
newdesign.structures(5).Dim(2) = t_good;
newdesign.structures(6).Dim(1) = t_good;
for j = 1:6
    newdesign.structures(j).Mass = newdesign.structures(j).Dim(1)...
        *newdesign.structures(j).Dim(2)*newdesign.structures(j).Dim(3)*material(mat_i).Density;
    newdesign.structures(j).Material = material(mat_i).Name;
end
newdesign.structureMass = sum([newdesign.structures.Mass]);
% newdesign.structureMass = newdesign.structures(1).Mass+newdesign.structures(2).Mass...
%     +newdesign.structures(3).Mass+ newdesign.structures(4).Mass...
%     +newdesign.structures(5).Mass+ newdesign.structures(6).Mass;
%    +newdesign.structures(7).Mass+ newdesign.structures(8).Mass;
%newdesign.structureMass = sum(newdesign.structures.Mass);
newdesign.structuresCost = structures.structuresMass*material(mat_i).Cost;
newdesign.totalMass = structures.structuresMass + structures.componentsMass;
            
        
% n1 = length(structures);
% Get the structures assignment
%structuresAssignment = cat(1,components.structuresAssignment);

% for i = 1:n1
%     index = ismember(structuresAssignment(:,1),i,'rows');
%     if strcmp(structures(i).Shape,'Rectangle')
%         if ~strcmp(structures(i).Plane,'XY')
%             % If the panel is a column
%             [thickness] = PanelBuckling(P,width,thickness,E,height);
%             
%         else
%             % If the panel is not a column
%             
%         end
%     elseif strcmp(structures(i).Shape,'Cylinder Hollow')
%     elseif strcmp(structures(i).Shape,'Sphere')
%     elseif strcmp(structures(i).Shape,'Cylinder')
%     elseif strcmp(structures(i).Shape,'Cone')
%         
%         
%     end
%
%     
% end
% 
% % We want to cycle through each of the materials and see which one gives
% % the least cost for the thickness. 
% material =  MaterialTable();
% 
% function [thickness] = PanelBuckling(P,width,thickness,E,height)
% % Using a safety factor of 1.5, calculate the critical force.
% SF = 1.5;
% Pcr = P*SF;
% 
% % Assuming that the panel is cantilevered,
% Le = 2*height;
% 
% % Pcr = pi^2*E*crossI/Le^2;
% % Check for buckling in both X and Y axes
% % crossI = width*thickness^3/12;
% thickness= ((Pcr*Le^2/(pi^2*E))*(Le^2/width))^3;
% end
% 
% function CylinderBuckling()
% end
% 
% function BeamBending()
% end
% 
% 
% function ModalAnalysis()
% % m would be the sum of everything except for payload
% % m_p would be payload mass
% % L would be the current initHeight
% % What do I use as the E
% % What do I use as the I, should I just grab the Ixx and Iyy from the
% % matrix?
% % What do I use as the A
% I = (fnat_lat/0.276)^2*(m*L^3 + 0.236*m_p*L^3)/E;
% A = (fnat_ax/0.160)^2*(m*L + 0.333*m_p*L)/E;
% end
% end

end


