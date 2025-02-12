function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m

%First Layer

X_1 = ones(m, 1); %creating the bias unit
a1 = [X_1 X]; %matrix with bias unit 5000*401

%Second Layer
z2 = a1*Theta1';
a2 = sigmoid(z2); %5000 * 25


a2_1 = ones(size(a2, 1), 1); %creating bias unit
a2 = [a2_1 a2]; %matrix with bias unit

%Final Layer
z3 = a2*Theta2'; %5000 * 10
a3 = sigmoid(z3);

%prediction
h_x = a3;

y_vec = zeros(size(y,1), num_labels); %5000 * 10
for i = 1:size(X,1)
    y_vec(i, y(i)) = 1;
end    

J = sum(sum(y_vec.*log(h_x) + (1-y_vec).*log(1-h_x)));
J = -J/m;
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. (In our case from 1 to 10)
%               You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.


delta3 = a3 - y_vec; %5000*10

%delta2 = delta3*Theta2.*[ones(size(z2, 1), 1) sigmoidGradient(z2)]; % (5000*10)'*(10*25).*(5000*26).*(5000*26) %5000*26
delta2 = delta3*Theta2.*a2.*(1-a2);
delta2 = delta2(:, 2:end);

DELTA1 = zeros(hidden_layer_size, input_layer_size + 1) ; %25*401
DELTA2 = zeros(num_labels, hidden_layer_size + 1); %10*26

%size(DELTA1)
%size(a1)
%size(delta2)
%size(Theta1)

DELTA1 = DELTA1 + delta2'*a1; % (5000*25)'*(5000*401)
DELTA2 = DELTA2 + delta3'*a2; % (5000*10)'*(5000*26)



%size(DELTA2)
%size(a2)
%size(delta3)
%size(Theta2)

Theta1_grad = (1/m) * DELTA1;
Theta2_grad = (1/m) * DELTA2;


%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%


%Adding the regularization term of both the layers
reg_term = (lambda/(2*m)) * (sum(sum(Theta1(:,2:end).^2)) + sum(sum(Theta2(:,2:end).^2))); %scalar
J = J + reg_term;

%Gradient Descent (with regularization, but not for biased unit)
Theta1_grad = Theta1_grad + (lambda/m) * [zeros(hidden_layer_size, 1) , Theta1(:, 2:end)];
Theta2_grad = Theta2_grad + (lambda/m) * [zeros(num_labels, 1) , Theta2(:, 2:end)];

% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
