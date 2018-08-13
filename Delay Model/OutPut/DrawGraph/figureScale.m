function vector_output = figureScale(vector_input,threshold,scale_k,scale_b)

NF=length(vector_input);
vector_output=vector_input;

for ii=1:NF
    if vector_input(ii)<=threshold(1)
        vector_output(ii)=vector_input(ii)*scale_k(1)+scale_b(1);
    else
        if (threshold(1)<vector_input(ii))&&(vector_input(ii)<=threshold(2))
           vector_output(ii)=vector_input(ii)*scale_k(2)+scale_b(2); 
        else
           vector_output(ii)=vector_input(ii)*scale_k(3)+scale_b(3);  
        end
    end
end

end

