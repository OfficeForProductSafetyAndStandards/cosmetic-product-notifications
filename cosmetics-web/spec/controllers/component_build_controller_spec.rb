require 'rails_helper'

RSpec.describe ComponentBuildController, type: :controller do
    before do
        authenticate_user
    end

    after do
        sign_out_user
    end

    describe "GET #new" do
        it "it redirects to the first step of the wizard" do
            component = create_component
            get(:new, params: { component_id: component.id })
            expect(response).to redirect_to(
                component_build_path(component.id, "number_of_shades"))
        end
    end

    describe "GET #show" do
        it "assigns the correct notification" do
            component = create_component
            get(:show, params: { component_id: component.id, id: 'number_of_shades' })
            expect(assigns(:component)).to eq(component)
        end

        it "renders the step template" do
            component = create_component
            get(:show, params: { component_id: component.id, id: 'number_of_shades' })
            expect(response).to render_template(:number_of_shades)
        end

        it "redirects to the check your answers page on finish" do
            component = create_component
            get(:show, params: { component_id: component.id, id: 'wicked_finish' })
            expect(response).to redirect_to(edit_notification_path(component.notification))
        end

        it "initialises shades array with two empty strings in add_shades step" do
            component = create_component
            get(:show, params: { component_id: component.id, id: 'add_shades' })
            expect(assigns(:component).shades).to eq([ '', '' ])
        end
    end

    describe "POST #update" do
        it "assigns the correct notification" do
            component = create_component
            post(:update, params: { component_id: component.id, id: 'number_of_shades',
                                    component: { shades: [] } })
            expect(assigns(:component)).to eq(component)
        end

        it "updates notification parameters if present" do
            component = create_component
            post(:update, params: { component_id: component.id, id: 'add_shades',
                                    component: { shades: [ 'red', 'blue' ] } })
            expect(component.reload.shades).to eq([ 'red', 'blue' ])
        end

        it "proceeds to add_shades step if user wants to add shades" do
            component = create_component
            post(:update, params: { component_id: component.id, id: 'number_of_shades',
                                    number_of_shades: 'multiple' })
            expect(response).to redirect_to(
                component_build_path(component.id, "add_shades"))
        end

        it "skips add_shades step if user doesn't want to add shades" do
            component = create_component
            post(:update, params: { component_id: component.id, id: 'number_of_shades',
                                    number_of_shades: 'single' })
            expect(response).to redirect_to(edit_notification_path(component.notification))
        end

        it "adds empty string to shades array if add_shade parameter passed" do
            component = create_component
            post(:update, params: { component_id: component.id, id: 'add_shades',
                                    component: { shades: [ 'red', 'blue' ] }, add_shade: true })
            expect(assigns(:component).shades).to eq([ 'red', 'blue', '' ])                                 
        end

        it "removes shade from list if passed remove_shade_with_id" do
            component = create_component
            post(:update, params: { component_id: component.id, id: 'add_shades',
                                    component: { shades: [ 'red', 'blue', 'yellow' ] }, remove_shade_with_id: 1 })
            expect(assigns(:component).shades).to eq([ 'red', 'yellow' ])  
        end

        it "adds an emty string to shades if removing an element would leave less than two" do
            component = create_component
            post(:update, params: { component_id: component.id, id: 'add_shades',
                                    component: { shades: [ 'red', 'blue' ] }, remove_shade_with_id: 0 })
            expect(assigns(:component).shades).to eq([ 'blue', '' ])  
        end

        it "rerenders add_shades if less than two non blank shades are present" do
            component = create_component
            post(:update, params: { component_id: component.id, id: 'add_shades',
                                    component: { shades: [ 'red', '' ] } })
            expect(response).to render_template("component_build/add_shades")                                    
        end
    end

    private

    def create_component
        notification = Notification.create
        notification.components.build
        notification.save
        notification.components.first
    end
end
