function b = BrainStep(robot, time);

b = robot.Brain;
fetchEstimatedHeading = robot.Odometer.EstimatedHeading;
fetchX = robot.Odometer.EstimatedPosition(1);
fetchY = robot.Odometer.EstimatedPosition(2);


totalPotentialDiffByX = b.PotentialWallNdiffX(fetchX,fetchY) + ...
                        b.PotentialWallEdiffX(fetchX,fetchY) + ...
                        b.PotentialWallSdiffX(fetchX,fetchY) + ...
                        b.PotentialWallWdiffX(fetchX,fetchY) + ...
                        b.PotentialObjectNWdiffX(fetchX,fetchY) + ...
                        b.PotentialObjectSEdiffX(fetchX,fetchY) + ...
                        b.PotentialGoalDiffX(fetchX,fetchY) + ...
                        b.PotentialFieldCornerNWdiffX(fetchX, fetchY) + ...
                        b.PotentialFieldCornerNEdiffX(fetchX, fetchY) + ...
                        b.PotentialFieldCornerSEdiffX(fetchX, fetchY) + ...
                        b.PotentialFieldCornerSWdiffX(fetchX, fetchY);
totalPotentialDiffByY = b.PotentialWallNdiffY(fetchX,fetchY) + ...
                        b.PotentialWallEdiffY(fetchX,fetchY) + ...
                        b.PotentialWallSdiffY(fetchX,fetchY) + ...
                        b.PotentialWallWdiffY(fetchX,fetchY) + ...
                        b.PotentialObjectNWdiffY(fetchX,fetchY) + ...
                        b.PotentialObjectSEdiffY(fetchX,fetchY) + ...
                        b.PotentialGoalDiffY(fetchX,fetchY)+ ...
                        b.PotentialFieldCornerNWdiffY(fetchX, fetchY) + ...
                        b.PotentialFieldCornerNEdiffY(fetchX, fetchY) + ...
                        b.PotentialFieldCornerSEdiffY(fetchX, fetchY) + ...
                        b.PotentialFieldCornerSWdiffY(fetchX, fetchY);
%    
% potentialFieldFormula = @(x,y,xp,yp, alpha, beta, gamma) ...
%     alpha*exp( -((x-xp)/beta).^2  -((y-yp)/gamma).^2);
% 
% potentialWallN = @(x,y) potentialFieldFormula (x, y, b.PotentialFieldWallN(1), b.PotentialFieldWallN(2), ...
%         b.PotentialFieldWallN(3), b.PotentialFieldWallN(4), b.PotentialFieldWallN(5));
% potentialWallE = @(x,y) potentialFieldFormula (x, y, b.PotentialFieldWallE(1), b.PotentialFieldWallE(2), ...
%         b.PotentialFieldWallE(3), b.PotentialFieldWallE(4), b.PotentialFieldWallE(5));   
% potentialWallS = @(x,y) potentialFieldFormula (x, y, b.PotentialFieldWallS(1), b.PotentialFieldWallS(2), ...
%         b.PotentialFieldWallS(3), b.PotentialFieldWallS(4), b.PotentialFieldWallS(5));  
% potentialWallW = @(x,y) potentialFieldFormula (x, y, b.PotentialFieldWallW(1), b.PotentialFieldWallW(2), ...
%         b.PotentialFieldWallW(3), b.PotentialFieldWallW(4), b.PotentialFieldWallW(5));  
% potentialCornerNW = @(x,y) potentialFieldFormula (x, y, b.PotentialFieldCornerNW(1), b.PotentialFieldCornerNW(2), ...
%         b.PotentialFieldCornerNW(3), b.PotentialFieldCornerNW(4), b.PotentialFieldCornerNW(5));
% potentialCornerNE = @(x,y) potentialFieldFormula (x, y, b.PotentialFieldCornerNE(1), b.PotentialFieldCornerNE(2), ...
%         b.PotentialFieldCornerNE(3), b.PotentialFieldCornerNE(4), b.PotentialFieldCornerNE(5));   
% potentialCornerSE = @(x,y) potentialFieldFormula (x, y, b.PotentialFieldCornerSE(1), b.PotentialFieldCornerSE(2), ...
%         b.PotentialFieldCornerSE(3), b.PotentialFieldCornerSE(4), b.PotentialFieldCornerSE(5));  
% potentialCornerSW = @(x,y) potentialFieldFormula (x, y, b.PotentialFieldCornerSW(1), b.PotentialFieldCornerSW(2), ...
%         b.PotentialFieldCornerSW(3), b.PotentialFieldCornerSW(4), b.PotentialFieldCornerSW(5));  
% potentialObjectNW = @(x,y) potentialFieldFormula (x, y, b.PotentialFieldObjectNW(1), b.PotentialFieldObjectNW(2), ...
%         b.PotentialFieldObjectNW(3), b.PotentialFieldObjectNW(4), b.PotentialFieldObjectNW(5));  
% potentialObjectSE = @(x,y) potentialFieldFormula (x, y, b.PotentialFieldObjectSE(1), b.PotentialFieldObjectSE(2), ...
%         b.PotentialFieldObjectSE(3), b.PotentialFieldObjectSE(4), b.PotentialFieldObjectSE(5));
% potentialGoal = @(x,y) potentialFieldFormula (x, y, b.PotentialFieldGoal(1), b.PotentialFieldGoal(2), ...    
% b.PotentialFieldGoal(3), b.PotentialFieldGoal(4), b.PotentialFieldGoal(5));  
% 
% 
% totalPotentialField = @(x,y) potentialWallN(x,y) + potentialWallS(x,y) + potentialWallE(x,y)+ potentialWallW(x,y) + ...
%     potentialObjectNW(x,y) + potentialObjectSE(x,y) + potentialGoal(x,y) + ...
% potentialCornerNW(x,y) + potentialCornerNE(x,y) + potentialCornerSE(x,y) + potentialCornerSW(x,y);
% [x, y] = meshgrid([-4.0:0.2:4], [-4.0:0.2:4]);
% surf(x, y, totalPotentialField(x,y));


totalPotentialNormalizer = sqrt(totalPotentialDiffByX^2 + totalPotentialDiffByY^2);
directionOfMotonX = - totalPotentialDiffByX/totalPotentialNormalizer;
directionOfMotonY = - totalPotentialDiffByY/totalPotentialNormalizer;

phiRef = atan2(directionOfMotonY, directionOfMotonX);

kpRegulator = 5;
deltaV = b.VNav * kpRegulator * (phiRef - fetchEstimatedHeading);
vL = b.VNav - (deltaV/2);
vR = b.VNav + (deltaV/2);

%%%%%%%%%%%%%%%% FSM: %%%%%%%%%%%%%%%%%%%%
if (b.CurrentState == 0) % Forward motion
 %robot.Speed = [vR, vL];
 b.LeftMotorSignal = vL;
 b.RightMotorSignal = vR;
 b.CurrentState = 0;
 
 distanceToGoal = sqrt( (b.PotentialFieldGoal(1)-fetchX)^2 + (b.PotentialFieldGoal(2)-fetchY)^2 );
 
 %[IN ON] = inpolygon(fetchX, fetchY,xCircle,yCircle);
 %[IN ON] = inpolygon(fetchX, fetchY,[b.PotentialFieldGoal(2)-0.4 b.PotentialFieldGoal(2)+0.4 b.PotentialFieldGoal(2)+0.4 b.PotentialFieldGoal(2)-0.4],...
 %                    [b.PotentialFieldGoal(1)+0.4 b.PotentialFieldGoal(1)+0.4 b.PotentialFieldGoal(1)-0.4 b.PotentialFieldGoal(1)-0.4]);
 if (distanceToGoal < 0.2)
  b.CurrentState = 1;
 end
elseif (b.CurrentState == 1) % Time to turn?
 b.LeftMotorSignal = 0;
 b.RightMotorSignal = 0;
%  r = rand;
%  if (r < b.TurnProbability)
%   s = rand;
%   if (s < b.LeftTurnProbability)
%    b.LeftMotorSignal  =  b.TurnMotorSignal;
%    b.RightMotorSignal = -b.TurnMotorSignal;
%   else
%    b.LeftMotorSignal  = -b.TurnMotorSignal;
%    b.RightMotorSignal =  b.TurnMotorSignal;
%   end
%   b.CurrentState = 2;
% end
elseif (b.CurrentState == 2) % Time to stop turning?
 r = rand;
 if (r < b.StopTurnProbability) 
  b.CurrentState = 0;
 end
end

