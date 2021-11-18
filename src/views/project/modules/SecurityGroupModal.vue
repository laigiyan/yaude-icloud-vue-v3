<template>
  <a-modal
    :title="title"
    :width="800"
    :visible="visible"
    :confirmLoading="confirmLoading"
    @ok="handleOk"
    @cancel="handleCancel"
    cancelText="關閉">
    <a-spin :spinning="confirmLoading">
      <a-form-model ref="form"  :label-col="labelCol" :wrapper-col="wrapperCol"  :model="model" :rules="validatorRules">

        <a-form-model-item label="安全群組名稱" :labelCol="labelCol" :wrapperCol="wrapperCol" prop="name">
          <a-input v-model="model.name" placeholder="請輸入安全群組名稱" ></a-input>
        </a-form-model-item>

        <a-form-model-item label="描述" :labelCol="labelCol" :wrapperCol="wrapperCol"   prop="description">
          <a-textarea v-model="model.description" placeholder="請輸入描述" ></a-textarea>
        </a-form-model-item>

        <a-form-model-item label="說明"  hasFeedback>
          <span>安全群組是作用於虛擬機網路接口上的一組IP過濾規則。安全群組創建完成後，你可以向其中添加規則。</span>
        </a-form-model-item>

      </a-form-model>
    </a-spin>
  </a-modal>
</template>

<script>
  import { getAction,httpAction } from '@/api/manage'

  export default {
    name: "SecurityGroupModal",
    data () {
      return {
        title:"新增",
        visible: false,
        model: {},
        layout: {
          labelCol: { span: 3 },
          wrapperCol: { span: 14 },
        },
        labelCol: {
          xs: { span: 24 },
          sm: { span: 3 },
        },
        wrapperCol: {
          xs: { span: 24 },
          sm: { span: 16 },
        },
        confirmLoading: false,
        form: this.$form.createForm(this),
        validatorRules:{
          name: [
            { required: true, message: '請輸入安全群組名稱!' },
          ],
          description: [
            { required: true, message: '請輸入安全群組描述!' },
          ],
        },
        url: {
          add:"/openstack/securityGroup/createSecurityGroup",
          edit:"/openstack/securityGroup/updateSecurityGroup",
        },
        inUseVolumes:[]
      }
    },
    created () {

    },
    methods: {
      add (record) {
        this.edit(record);
      },
      edit (record) {
        this.model = Object.assign({}, record);
        this.visible = true;
      },
      close () {
        this.$refs.form.resetFields();
        this.$emit('close');
        this.visible = false;
      },
      handleOk () {
        const that = this;
        // 觸發表單驗證
        this.$refs.form.validate(valid => {
          if (valid) {
            that.confirmLoading = true;
            debugger
            let httpurl = '';
            if(!this.model.securityGroupId){
              httpurl+=this.url.add;
            }else{
              httpurl+=this.url.edit;
            }
            getAction(httpurl,that.model).then((res)=>{
              if(res.success){
                that.$message.success(res.message);
                that.$emit('ok');
              }else{
                that.$message.warning(res.message);
              }
            }).finally(() => {
              that.confirmLoading = false;
              that.close();
            })
          }
        })
      },
      handleCancel () {
        this.close()
      },
    }
  }
</script>

<style scoped>

</style>