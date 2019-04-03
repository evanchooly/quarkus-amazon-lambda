package com.antwerkz.quarkus.lambda;

import com.amazonaws.services.lambda.runtime.Context;
import com.amazonaws.services.lambda.runtime.RequestHandler;

import javax.inject.Inject;

public class HelloLambda implements RequestHandler<HelloRequest, String> {

    @Inject
    HelloGreeter greeter;

    @Override
    public String handleRequest(HelloRequest request, final Context context) {
        return greeter.greet(request.firstName, request.lastName);
    }
}
